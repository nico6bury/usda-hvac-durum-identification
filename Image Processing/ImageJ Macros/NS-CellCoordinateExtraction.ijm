/*
 * AUthor: Nicholas Sixbury
 * File: NS-CellCoordinateExtraction.ijm
 * Purpose: To extract the raw coordinates from a single grid.
 * This macro is meant to be used with another program driving things.
 */

 arguments = getArgument();
 if(arguments == ""){
 	showMessageWithCancel("Unsupported Run Mode", "This macro does not support " +
 	"being run without arguments. Please try again with necessary arguments.");
 }//end if we have no arguments
 else{
 	/*
 	 * Argument List (what we should expect)
 	 * CellThresholdLower (lower threshold for threshold setting)
 	 * CellThresholdUpper (upper threshold for threshold setting)
 	 * SizeLimitLower (lower size limit for cell detection)
 	 * SizeLimitUpper (upper size limit for cell detection)
 	 * CircularityLower (lower limit for circularity in cell detection)
 	 * CircularityUpper (upper limit for circularity in cell detection)
 	 * InputFilepath (name of file to process)
 	 * ShouldFlip (whether or not we should flip the image before processing)
 	 * OutputFilepath (path we should export results to)
 	 */
 	 // split arguments into an array
 	 splitArgs = SplitArguments(arguments);
 	 // parse whichever values need parsing
 	 parsedArgs = EvaluateArguments(splitArgs);
 	 // set all out variables
 	 CellThresholdLower = parsedArgs[0];
 	 CellThresholdUpper = parsedArgs[1];
 	 SizeLimitLower = parsedArgs[2];
 	 SizeLimitUpper = parsedArgs[3];
 	 CircularityLower = parsedArgs[4];
 	 CircularityUpper = parsedArgs[5];
 	 InputFilepath = parsedArgs[6];
 	 ShouldFlip = parsedArgs[7];
 	 OutputFilepath = parsedArgs[8];
 	 // open the specified image
 	 open(InputFilepath);
 	 // analyze particle locations to results window and save stuff?
 	 DynamicCoordGetter();
 }//end else we have arguments

/*
 * returns an array of arguments split from string, making sure
 * to be quotation-intelligent
 */
function SplitArguments(string){
	// array to put all the new strings in
	rtnArr = newArray(9);
	// next index to add into for rtnArr
	nxtInd = 0;
	// string for keeping track of current arg we're building
	curArg = "";
	// whether we're looking for another quotation mark
	quotLook = false;
	for(i = 0; i < lengthOf(string); i++){
		curChar = substring(string, i, i+1);
		if(curChar == '|'){
			if(quotLook){
				// add this new section
				rtnArr[nxtInd] = curArg;
				nxtInd++; curArg = "";
			}//end if we were looking for this
			// always toggle quotLook
			quotLook = !quotLook;
		}//end if we found a quotation mark
		else if(curChar == ' ' && !quotLook){
			if(curArg != ""){
				// add new section to rtnArr
				rtnArr[nxtInd] = curArg;
				nxtInd++; curArg = "";
			}//end if curArg isn't empty
		}//end if we found a space
		else{
			curArg += curChar;
		}//end else we should just add this to the end of the array
	}//end looping over each char in string

	// grab anything left from last argument
	if(curArg != ""){
		rtnArr[nxtInd] = curArg;
		nxtInd++; curArg = "";
	}//end if we have something left in curArg
	
	return rtnArr;
}//end SplitArguments(string)

/*
 * Parses the arguments that should be parsed.
 */
function EvaluateArguments(args){
	args[0] = parseFloat(args[0]); // cell thresh lower
	args[1] = parseFloat(args[1]); // cell thresh upper
	args[2] = parseFloat(args[2]); // size limit lower
	if(args[3] != "Infinity"){
		args[3] = parseFloat(args[3]); // size limit upper
	}//end if upper limit isn't infinity
	args[4] = parseFloat(args[4]); // circ limit lower
	args[5] = parseFloat(args[5]); // circ limit upper
	args[7] = parseInt(args[7]); // if we should flip img first
	return args;
}//end EvaluateArguments

/*
 * runs commands to print all the coordinates to the results window
 */
function DynamicCoordGetter(){
	// save copy of image so we don't screw up the original
	makeBackup("coords");
	// flip image horizontally if we need to
	if(ShouldFlip){
		run("Flip Horizontally");
	}//end if we need to flip
	// change image to 8-bit grayscale for threshold setting
	run("8-bit");
	// set threshold
	setThreshold(CellThresholdLower, CellThresholdUpper);
	// set scale so we have the right dimensions
	run("Set Scale...", "distance=11.5 known=1 unit=mm global");
	// set measurements to only calculate what we want
	run("Set Measurements...", "bounding redirect=None decimal=1");
	// run particle analysis to detect cells as particles
	run("Analyze Particles...", 
	"size=SizeLimitLower-SizeLimitUpper circularity=CircularityLower-CircularityUpper " +
	"show=[Overlay Masks] display exclude include");
	if(!is("Batch Mode")){
		// get results from clipboard
		String.copyResults();
		results = String.paste();
		// make sure directory exists
		recursiveMakeDirectory(File.getDirectory(OutputFilepath));
		// create file if it doesn't exist, write results to it
		File.saveString(results, OutputFilepath);
	}//end if we're running in batch mode
	// restore the backup
	openBackup("coords", true);
}//end DynamicCoordGetter()

/*
 * Makes backup by to restore back to
 */
function makeBackup(appendation){
	// make backup in temp folder
	// figure out the folder path
	backupFolderDir = getDirectory("temp") + "imageJMacroBackup" + 
	File.separator;
	File.makeDirectory(backupFolderDir);
	backupFolderDir += "HVAC" + File.separator;
	// make sure the directory exists
	File.makeDirectory(backupFolderDir);
	// make file path
	filePath = backupFolderDir + "backupImage-" + appendation + ".tif";
	// save the image as a temporary image
	save(filePath);
}//end makeBackup()

/*
 * restores backup
 */
function openBackup(appendation, shouldClose){
	// closes active images and opens backup
	// figure out the folder path
	backupFolderDir = getDirectory("temp") + "imageJMacroBackup" + 
	File.separator + "HVAC" + File.separator;
	// make sure the directory exists
	File.makeDirectory(backupFolderDir);
	// make file path
	filePath = backupFolderDir + "backupImage-" + appendation + ".tif";
	// close whatever's open
	if(shouldClose == true) close("*");
	// open our backup
	open(filePath);
}//end openBackup

function recursiveMakeDirectory(directory){
	// makes directory even if it has to make multiple directories
	if(directory != 0){
		recursiveMakeDirectory(File.getParent(directory));
	}//end if we can go ahead and recurse
	File.makeDirectory(directory);
}//end recursiveMakeDirectory(directory)