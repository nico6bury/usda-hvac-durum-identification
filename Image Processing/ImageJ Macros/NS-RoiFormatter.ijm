/*
 * Author: Nicholas Sixbury
 * File: NS-RoiFormatter.ijm
 * Purpose: To create a formatted roi file based on a file of coordinates.
 */
arguments = getArgument();
actualFile = "";
outputPath = "C:/Users/nicholas.sixbury/Desktop/Programs/ImageJ Macro Driver/ImageJDriver/ImageJMacroD/bin/Debug/netcoreapp3.1/roi.zip";
//File.makeDirectory(outputPath);
if(arguments == ""){
	arguments = "C:\\Users\\nicholas.sixbury\\Desktop\\Programs\\ImageJ Macro Driver\\ImageJDriver\\ImageJMacroD\\bin\\Debug\\netcoreapp3.1\\roiText.txt";
	actualFile = "C:/Users/nicholas.sixbury/Desktop/Samples/Samples from Kate/" +
	"FGIS22-C-11-1-1OR-F.tif";
}//end if there are no arguments
else{
	parts = split(arguments, "*");
	arguments = parts[0];
	actualFile = parts[1];
	outputPath = parts[2];
}//end else we have arguments to parse

open(actualFile);
run("Flip Horizontally");
run("Set Scale...", "distance=11.5 known=1 unit=mm global");

// start getting stuff from the file
linesFromFile = File.openAsString(arguments);
linesFromFile = split(linesFromFile, '\n');
curRoi = 1;
for(i = 0; i < lengthOf(linesFromFile); i++){
	line = linesFromFile[i];
	firstChar = substring(line, 0, 1);
	if(firstChar != '\n' && firstChar != '\t'){
		parts = split(line, " \t");
		x = parseFloat(parts[0]);
		y = parseFloat(parts[1]);
		w = parseFloat(parts[2]);
		h = parseFloat(parts[3]);
		if(x == -2.0){
		}//end if new row
		else if(x == -1.0){
		}//end else if empty cell
		else{
			// make selection so roi manager can find it
			//print("x:" + x + " y:" + y);
			makeRectangle(x * 11.5, y * 11.5, w * 11.5, h * 11.5);
			nextIndex = roiManager("count");
			roiManager("add");
			roiManager("select", nextIndex);
			roiManager("rename", curRoi);
			curRoi++;
		}//end else normal coordinates
	}//end if we have a normal line here
}//end looping over each line

roiManager("save", outputPath);
