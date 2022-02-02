package seedDataProcessor;

import java.util.List;
import java.util.ArrayList;

/**
 * This class represents a single seed,
 * comprised of some number of seed
 * lines.
 * @author Nicholas Sixbury
 * @see SeedLine
 */
public class Seed {
    /**
     * The list of lines that make up this seed.
     */
    protected List<SeedLine> lines = new ArrayList<SeedLine>();

    /**
     * Gets all the lines that make up this seed.
     * @return List of SeedLines
     */
    public List<SeedLine> getLines(){
        List<SeedLine> tempList = new ArrayList<SeedLine>();
        for(SeedLine line : lines){
            tempList.add(line);
        }//end looping over lines
        return tempList;
    }//end getLines()

    /**
     * Gets the seed line at a particular index
     * @param index
     * @return SeedLine at specified index
     */
    public SeedLine getLine(int index){
        return lines.get(index);
    }//end getLine(index)

    /**
     * Replaces current list of lines with new one.
     * @param lines
     */
    public void setLines(List<SeedLine> lines){
        if(lines != null){
            List<SeedLine> tempList = new ArrayList<SeedLine>();
            for(SeedLine line : lines){
                SeedLine newLine = new SeedLine(line);
                //newLine.CurrentCellOwner = this;
                tempList.add(newLine);
            }//end adding all lines
            lines = tempList;
        }//end if the value isn't null
        else{
            throw new IllegalArgumentException("You cannot set a Seed's internal seed list to null.");
        }//end else the value is null
    }//end setLines(lines)

    /**
     * Replaces one line in list of lines.
     * @param index
     * @param line
     */
    public void setLine(int index, SeedLine line){
        lines.set(index, line);
    }//end setLine(index, line)

    /**
     * The number of lines in this seed.
     */
    public int size(){
        return lines.size();
    }//end size()

    /**
     * Whether or not Seeds will factor germ detection
     * into any calculations.
     */
    public static boolean useGermDetection = true;

    /**
     * Whether or not this seed consists of a
     * single line which is a newRowFlag
     * @return true if new row flag, false otherwise
     */
    public boolean isNewRowFlag(){
        // if we have wrong number of lines
        if(lines.size() != 1) return false;
        // if the flag is wrong
        if(!lines.get(0).isNewRowFlag()) return false;
        // if we got here, we must be true
        return true;
    }//end isNewRowFlag()

    /**
     * Whether or not this seed starts with a start
     * flag and ends with an end flag.
     * @return true if full cell, false otherwise.
     */
    public boolean isFullCell(){
        // if there aren't enough lines
        if(lines.size() < 2) return false;
        // if the first line isn't a start flag
        if(!lines.get(0).isSeedStartFlag()) return false;
        // if the last row isn't an end flag
        if(!lines.get(lines.size()-1).isSeedEndFlag()) return false;
        // if we got here, it must be true
        return true;
    }//end ifFullCell()

    /**
     * Whether or not this cell is just a
     * start flag and end flag, with no data,
     * and empty cell.
     * @return true if empty cell, false otherwise
     */
    public boolean isEmptyCell(){
        // if there aren't the right amount of lines
        if(lines.size() != 2) return false;
        // if first row isn't start flag
        if(!lines.get(0).isSeedStartFlag()) return false;
        // if last row isn't an end flag
        if(!lines.get(1).isSeedEndFlag()) return false;
        // if we got here, it must be true
        return true;
    }//end isEmptyCell()

    /**
     * The chalkiness of this seed. If this is a new row flag,
     * an empty cell, or incorrectly formatted, then this will
     * return -2, -0.1, or -10 respectively. Otherwise, it will
     * return percent chalkiness of this cell as a percent. If
     * the seed is a germ, returns 1%.
     */
    public double getChalk(){
        if(isNewRowFlag()) return -2;
        else if(!isFullCell()) return -10;
        else if(isEmptyCell()) return -0.1;
        else if(useGermDetection == false){
            return calculateChalk();
        }//end else if we should disregard germs
        else{
            if(isGerm() && !twoSpots()){
                return 0.01 * 100;
            }//end if this seed has a germ on it.
            else if(lines.size() == 4){
                // just normal chalk area divided by kernel area
                return lines.get(2).area / lines.get(1).area * 100;
            }//end if we have the normal amount of lines
            else if(lines.size() == 5){
                if(isGerm() && twoSpots()){
                    // divide third data row area (chalk)
                    // by first data row area (kernel)
                    return lines.get(3).area / lines.get(1).area * 100;
                }//end if we should exclude area of the germ
                else{
                    // add both chalk areas together and
                    // divide by kernel area
                    double totalChalk = lines.get(2).area +
                    lines.get(3).area;
                    return totalChalk / lines.get(1).area * 100;
                }//end else we have normal instance of weird chalk
            }//end else we have two rows of chalkiness
            else{
                return 0.01 * 100;
            }//end else seed has very little chalk
        }//end else we should account for germs
    }//end getChalk()

    /**
     * The chalkiness of this seed. This method doesn't take
     * germ potential into account.
     * @return
     */
    public double calculateChalk(){
        if(isNewRowFlag()) return -2;
        else if(!isFullCell()) return -10;
        else if(isEmptyCell()) return -0.1;
        else{
            if(lines.size() == 4){
                return lines.get(2).area / lines.get(1).area * 100;
            }//end if we have the normal amount of lines
            else if(lines.size() == 5){
                double totalChalk = lines.get(2).area + lines.get(3).area;
                return totalChalk / lines.get(1).area * 100;
            }//end else if we have two rows of chalkiness
            else{
                return 0.01*100;
            }//end else we must have a seed with very little chalk
        }//end else this must be a complete cell
    }//end calculateChalk()

    private double germThreshold = 0.5;
    public double getGermThreshold(){
        return germThreshold;
    }//end getGermThreshold
    public void setGermThreshold(double value){
        germThreshold = value;
        if(germThreshold < 0) germThreshold = 0;
    }//end setGermThreshold(value)

    /**
     * The number of lines in this seed, minus 2 to account
     * for start and end flags.
     * @return
     */
    public int getLineSpan(){
        return lines.size() - 2;
    }//end getLineSpan()

    /**
     * This is the x of the spot on the seed that represents chalk
     * minus the x of the kernel. Doesn't take any potential third
     * data row into account if it exists.
     */
    public double dx(){
        if(getLineSpan() < 2){
            // return arbitrary small value
            return 0;
        }//end if data rows are less than 2
        else{
            // get kernel X
            double kernel = lines.get(1).x;
            // add first spot
            double spots = lines.get(2).x;
            //// add second spot if there
            //if(getLineSpan() == 3) spots += lines.get(3).x;
            return spots - kernel;
        }//end else we can calculate stuff
    }//end dx
    /**
     * Same as dx but for y instead of x.
     */
    public double dy(){
        if(getLineSpan() < 2){
            // return arbitrary small value
            return 0;
        }//end if data rows are less than 2
        else{
            // get kernel X
            double kernel = lines.get(1).y;
            // add first spot
            double spots = lines.get(2).y;
            //// add second spot if there
            //if(getLineSpan() == 3) spots += lines.get(3).y;
            return spots - kernel;
        }//end else we can calculate stuff
    }//end dy
    /**
     * ((dx^2)+(dy^2))^(0.5), top of ratio
     */
    public double z(){
        double dx2 = dx() * dx();
        double dy2 = dy() * dy();
        double result = Math.sqrt(dx2 + dy2);
        return result;
    }//end z()
    /**
     * The major of the kernel row, divided by 2, bottom of ratio.
     */
    public double halfMajor(){
        if(getLineSpan() < 1){
            return 0.0001;
        }//end if there are no data rows
        else{
            return lines.get(1).major / 2.0;
        }//end else we can calculate half major
    }//end halfMajor()
    /**
     * the number of lines between the start and end flags that
     * we have detected fro the specified seed
     * @return
     */
    public int detectedDataRows(){
        // whether we should increment counter
        boolean flag = false;
        // the number of rows we're looking for
        int counter = 0;
        for(SeedLine line : lines){
            if(line.isSeedEndFlag()) flag = false;
            if(flag) counter++;
            else{
                if(line.isSeedStartFlag()) flag = true;
            }//end else flag false
        }//end looping
        return counter;
    }//end detectedDataRows()
    /**
     * fraction of z / halfMajor as double
     */
    public double ratio(){
        return z() / halfMajor();
    }//end ratio
    /**
     * Whether or not this cell seems to contain a germ. Doesn't
     * account for twoSpots.
     */
    public boolean isGerm(){
        return ratio() > germThreshold;
    }//end isGerm()
    /**
     * Whether or not there are two spots on this seed.
     * @return
     */
    public boolean twoSpots(){
        // check to make sure stuff isn't broken
        int dataRows = detectedDataRows();
        return dataRows > 2;
    }//end twoSpots()

    /**
     * A static definition for a seed with nothing in it
     * @return
     */
    public static Seed blankSeed(){
        Seed blankSeed = new Seed();
        return blankSeed;
    }//end blankSeed()

    /**
     * Initializes this object with no default data.
     */
    public Seed(){
        lines = new ArrayList<SeedLine>();
    }//end no-arg constructor

    /**
     * Initializes this object as a copy of the specified seed object.
     * @param seed THe seed you wish to copy.
     */
    public Seed(Seed seed){
        // creates deep copy
        lines = new ArrayList<SeedLine>();
        for(SeedLine line : seed.getLines()){
            lines.add(new SeedLine(line));
        }//end adding lines to seed
        ownSeedLines();
    }//end 1-arg copy constructor

    /**
     * Initializes this object with a single line.
     * @param line The SeedLine which will be initialized into lines.
     */
    public Seed(SeedLine line){
        lines.add(new SeedLine(line));
    }//end 1-arg line constructor

    /**
     * Initializes this object with its lines initialized as the
     * specified list of lines.
     * @param lines The list of lines to initialize this object with.
     */
    public Seed(List<SeedLine> lines){
        // creates deep copy
        lines = new ArrayList<SeedLine>();
        for(SeedLine line : lines){
            lines.add(new SeedLine(line));
        }//end adding lines to seed
    }//end 1-arg list constructor

    /**
     * The string representation of this object, in this case a
     * string containing the toStrings of all its seedLines, with
     * the \n character in between.
     */
    public String toString(){
        StringBuilder sb = new StringBuilder();
        for(SeedLine line : lines){
            sb.append(line.toString() + "\n");
        }//end getting string data from each row in rows
        return sb.toString();
    }//end toString()

    /**
     * Two seed objects are equal if all seedLines are equal.
     * @param other
     * @return
     */
    public boolean equals(Seed other){
        // check for right length
        if(other.size() != this.size()) return false;
        // check for individual row equality and order
        for(int i = 0; i < other.size(); i++){
            if(!other.getLine(i).equals(getLine(i))) return false;
        }//end looping through each line in other seed
        // if we managed to get here, they must be equal
        return true;
    }//end equals(other)

    /**
     * Adds a new seed line to the end of lines.
     * @param item The line to add.
     */
    public void add(SeedLine item){
        lines.add(item);
        item.currentSeedOwner = this;
    }//end add(item)

    /**
     * Clears the list of lines.
     */
    public void clear(){
        lines.clear();
    }//end clear()

    /**
     * Returns whether or not a specified item is contained within
     * this seed.
     * @param item The seedLine to look for
     * @return true if the item was found, false otherwise
     */
    public boolean contains(SeedLine item){
        for(SeedLine line : lines){
            if(item.equals(line)) return true;
        }//end checking each line
        // if we got here, we must not have found it
        return false;
    }//end contains(item)

    /**
     * Ensures that all seed line objects ahve their owner set to
     * this object.
     */
    public void ownSeedLines(){
        for(SeedLine line : lines){
            line.currentSeedOwner = this;
        }//end owning all lines in this object
    }//end ownSeedLines()
}//end class Seed
