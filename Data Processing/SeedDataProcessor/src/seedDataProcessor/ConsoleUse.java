package seedDataProcessor;

import java.awt.*;
import java.awt.event.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import javax.swing.JOptionPane;

/**
 * This is just a somewhat temporary class
 * in order to quickly use and test java
 * seed processing.
 */
public class ConsoleUse {
    private static Frame mainFrame;
    private static Label headerLabel;
    private static Label statusLabel;
    private static Panel controlPanel;
    private static File[] filesToImport;
    private static String outputPath;
    public static void main(String[] args){
        SeedLine.putDefaultColumnAlias();
        prepareGUI();
        getFilesToImport();
        // boolean alwaysContinue = true;
        // while(alwaysContinue){
        //     // just wait around, I guess?
        // }//end application loop
    }//end main method

    private static void prepareFiles(File[] files){
        for(File file : filesToImport){
            // get the useable information from the file
            List<SeedLine> lines = getSeedLines(file);
            // parse that info into a more structured format
            List<Seed> seeds = parseSeeds(lines);
            // count up the levels
            int[] levels = levelCount(seeds);
            // make a little message for the user
            JOptionPane.showMessageDialog(mainFrame, "In file " +
            file.getName() + ", found " +
            countNonFlags2(lines) + " data lines and " +
            countNonFlags1(seeds) + " seeds. Nonflags, of course.\n"+
            "Also, there were " + levels[0] + " seeds in level1, "+
            levels[1] + " seeds in level2, " + levels[2] + "seeds in "
            + "level3, and " + levels[3] + " seeds in level4.");
        }//end looping over each file we need to import
    }//end prepareFiles(files)

    private static void prepareGUI(){
        mainFrame = new Frame("Java Seed Data Processing");
        mainFrame.setSize(400,400);
        mainFrame.setLayout(new GridLayout(3,1));
        mainFrame.addWindowListener(new WindowAdapter(){
            public void windowClosing(WindowEvent windowEvent){
                System.exit(0);
            }//end window closing event
        });
        headerLabel = new Label();
        headerLabel.setAlignment(Label.CENTER);
        statusLabel = new Label();
        statusLabel.setAlignment(Label.CENTER);

        controlPanel = new Panel();
        controlPanel.setLayout(new FlowLayout());

        mainFrame.add(headerLabel);
        mainFrame.add(controlPanel);
        mainFrame.add(statusLabel);
        mainFrame.setVisible(true);
    }//end prepareGUI()

    private static File[] getFilesToImport(){
        headerLabel.setText("Getting Files");

        FileDialog fileDialog = new FileDialog(mainFrame,
        "Select Files to process.");
        fileDialog.setMultipleMode(true);
        Button showFileDialogButton = new Button("Open Files");
        showFileDialogButton.addActionListener(new ActionListener(){
            @Override
            public void actionPerformed(ActionEvent e){
                fileDialog.setVisible(true);
                filesToImport = fileDialog.getFiles();
                statusLabel.setText("Selected " + filesToImport.length + " files.");
                prepareFiles(filesToImport);
            }//end getting files
        });
        controlPanel.add(showFileDialogButton);
        mainFrame.setVisible(true);
        filesToImport = fileDialog.getFiles();
        fileDialog.dispose();
        return filesToImport;
    }//end showFileDialog()

    /**
     * Parses all the lines of a file into seedLines.
     * @apiNote The following column-reading code makes several
        assumptions. It assumes that a space instead of a
        column indicates the line number. It assumes that
        columns and data are separated by the \t character.
        It assumes that the line number is the first number
        on a row. If these assumptions are incorrect, then
        the code below will not function properly.
     * @param file The file to get SeedLine information from. It
     * should have column labels in the first line, and everything else
     * should be data.
     * @return List of parsed SeedLine objects
     */
    public static List<SeedLine> getSeedLines(File file){
        List<SeedLine> seedLines = new ArrayList<SeedLine>();
        try{
            // get the content of each line
            List<String> lines = Files.readAllLines(file.toPath());
            // read the column data
            List<String> columns = new ArrayList<String>();
            // separate first row by tab character
            StringTokenizer columnTokenizer =
            new StringTokenizer(lines.get(0),"\t");
            // process each token (should be ~1 column per token)
            while(columnTokenizer.hasMoreTokens()){
                String thisToken = columnTokenizer.nextToken();
                if(thisToken.equals(" ")){
                    // don't do anything
                }//end if this is the line number column
                else{
                    columns.add(thisToken);
                }//end else this is a normal column, probably
            }//end looping over each column
            // loop over each line after first, constructing SeedLine
            StringTokenizer dataTokenizer;
            for(int i = 1; i < lines.size(); i++){
                // split up this line by tab characters
                dataTokenizer = new StringTokenizer(lines.get(i),"\t");
                // save first token
                String lineNumStr = dataTokenizer.nextToken();
                // get all the other tokens
                List<String> dataStr = new ArrayList<String>();
                while(dataTokenizer.hasMoreTokens()){
                    String thisToken = dataTokenizer.nextToken();
                    if(!thisToken.equals("") && !thisToken.equals(" ")){
                        dataStr.add(thisToken);
                    }//end if this token has something in it
                }//end looping over rest of the tokens
                // parse the line number
                int lineNum = Integer.parseInt(lineNumStr);
                // finally construct the seedLine object
                SeedLine seedLine = new SeedLine(columns, dataStr, lineNum);
                // add that object to our list
                seedLines.add(seedLine);
            }//end looping over each line, minus first one
        }//end trying to read stuff
        catch (IOException e){
            e.printStackTrace();
        }//end catching IOExceptions
        return seedLines;
    }//end getSeedLines(file)

    private static List<Seed> parseSeeds(List<SeedLine> lines){
        List<Seed> seeds = new ArrayList<Seed>();
        // initialize some helpful variables
        boolean exceptionEncountered = false;
        StringBuilder eb = new StringBuilder();
        eb.append("\tThe following exceptions were encountered: ");

        // start looping through everything
        for(int i = 0; i < lines.size(); i++){
            SeedLine line = lines.get(i);
            // check to make sure we have some cells already
            if(seeds.size() == 0){
                seeds.add(new Seed(line));
                continue;
            }//end if we should just add it and stop
            
            // initialize some reference variables
            Seed lastSeed = seeds.get(seeds.size() - 1);

            // start figuring out where and what to add
            if(line.isNewRowFlag()){
                // adds the row as a new cell with single row
                seeds.add(new Seed(line));
                // sanity check + error tracking
                if(!lastSeed.isFullCell() && !lastSeed.isNewRowFlag()){
                    eb.append("\nDoubleNewRowException at lineNum of "
                    + line.lineNum);
                    exceptionEncountered = true;
                }//end if something weird happened
            }//end if the line is new row flag
            else if(line.isSeedStartFlag()){
                // adds the line as a new seed with single line
                seeds.add(new Seed(line));
                // sanity check + error tracking
                if(!lastSeed.isFullCell() && !lastSeed.isNewRowFlag()){
                    eb.append("\nPriorCellIncompleteException at "
                    + "lineNum of " + line.lineNum);
                    exceptionEncountered = true;
                }//end if something weird happened
            }//end else if line is seedStartFlag
            else{
                // Note: Why should we just append here?
                // the answer is that unless the implementation has
                // changed, the line must be either a seedEndFlag
                // or a data row, and in both cases should be added
                // to a prior seed. We only advance to a new seed
                // object if we encounter a newRowFlag or a
                // seedStartFlag.
                lastSeed.add(line);
            }//end else just append this row to end of last seed
        }//end main loop?
        if(exceptionEncountered){
            JOptionPane.showMessageDialog(mainFrame, eb.toString());
        }//end if exception was encountered
        return seeds;
    }//end parseSeeds(lines)

    private static int countNonFlags1(List<Seed> seeds){
        int counter = 0;
        for(Seed seed : seeds){
            if(!seed.isNewRowFlag() && !seed.isEmptyCell()) counter++;
        }
        return counter;
    }//end countNonFlags(seeds)

    private static int countNonFlags2(List<SeedLine> lines){
        int counter = 0;
        for(SeedLine line : lines){
            if(!line.isNewRowFlag() && !line.isSeedStartFlag()
            && !line.isSeedEndFlag()) counter++;
        }
        return counter;
    }//end countNonFlags(lines)

    private static int[] levelCount(List<Seed> seeds){
        int[] levels = new int[4];
        Seed.useGermDetection = true;
        for(Seed seed : seeds){
            double chalk = seed.getChalk();
            if(chalk >= 0 && chalk < 10) levels[0]++;
            else if(chalk >= 10 && chalk < 25) levels[1]++;
            else if(chalk >= 25 && chalk < 45) levels[2]++;
            else if(chalk >= 45) levels[3]++;
        }//end tallying up chalk levels
        return levels;
    }//end levelCount(seeds)
}//end class ConsoleUse
