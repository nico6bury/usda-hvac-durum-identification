/*
 * Author: Nicholas Sixbury
 * File: NS-MacroD-vAugust2021.ijm
 * Purpose: To handle all the processing for a single grid and 
 * output results quickly and efficiently.
 */
///////////////////////////////////////////////////////////////
//////////// BEGINNING OF MAIN FUNCTION ///////////////////////
// "Global" variables that we'll use "throughout"

// whether or not we'll use batch mode, which really speeds things up
useBatchMode = false;
// all the valid selection methods we might use
selectionMethods = newArray("Single File", "Multiple Files", "Directory");
// the path of the file we're processing. Might be a directory
chosenFilePath = "";
// the selection method we're actually going with
selectionMethod = selectionMethods[2];
// whether we should output chalk pictures
shouldOutputChalkPics = false;
// whether we should output flipped images for human reference
shouldOutputFlipped = false;
// whether or not we should show routine error messages during processing
shouldShowRoutineErrors = true;
// whether or not we should display a helpful progress bar for the user
shouldDisplayProgress = true;
// whether we should wait for the user during processing
shouldWaitForUserProc = false;
shouldOutputAnyResults = true;
// valid operating systems
validOSs = newArray("Windows 10", "Windows 7");
// chosen operating system
chosenOS = validOSs[0];

// whether or not we should output to a new folder for proccessed stuff
outputToNewFolderProc = true;
// what we should name our folder if we are using one
newFolderNameProc = "Results Folder";
// whether or not we should output a file of processed results
shouldOutputProccessed = true;
// the name of the file with processed results
procResultFilename = "Processed Results";
// the strings we don't allow in files we open via directory
forbiddenStrings = newArray("-Fx","-fA2","-F","-Skip");

// whether we should wait for the user during raw coordinate finding
shouldWaitForUserRaw = false;
shouldOutputAnyCoords = true;

// raw coordinate variables
// whether or not we should output to a new folder for raw coordinates
outputToNewFolderRaw = true;
// what we should name our folder if we are using one
newFolderNameRaw = "Results Folder";
// whether or not we should output a file of raw coordinates
shouldOutputRawCoords = true;
// the name of the file with the raw coordinates for the cells
rawCoordFilename = "Raw Cell Coordinates";

// processed coorindates variables
outputToNewFolderProcCoord = true;
newFolderNameProcCoord = "Results Folder";
shouldOutputProcCoords = true;
crctCoordsFilename = "Corrected Coordinates";
formCoordsFilename = "Formatted Coordinates";

// grouped coordinates variables
outputToNewFolderGroups = true;
newFolderNameGroups = "Results Folder";
shouldOutputGroups = true;
rawGroupsFilename = "Raw Group Coordinates";
procGroupsFilename = "Re-Processed Group Coordinates";

// the name of the file we'll open
chosenFilePath = "Default String Value For chosenFilePath";

// a somehwat helpful array for later
chalkNames = newArray(
		   "00-0","00-1","00-2","00-3",
	"01-0","01-1","01-2","01-3","01-4","01-5",
	"02-0","02-1","02-2","02-3","02-4","02-5",
	"03-0","03-1","03-2","03-3","03-4","03-5",
	"04-0","04-1","04-2","04-3","04-4","04-5",
	"05-0","05-1","05-2","05-3","05-4","05-5",
	"06-0","06-1","06-2","06-3","06-4","06-5",
		   "07-0","07-1","07-2","07-3",
	"08-0","08-1","08-2","08-3","08-4","08-5",
	"09-0","09-1","09-2","09-3","09-4","09-5",
	"10-0","10-1","10-2","10-3","10-4","10-5",
	"11-0","11-1","11-2","11-3","11-4","11-5",
	"12-0","12-1","12-2","12-3","12-4","12-5",
	"13-0","13-1","13-2","13-3","13-4","13-5",
		   "14-0","14-1","14-2","14-3");

arguments = getArgument();
if(arguments == ""){
	// try to load settings from file
	deserializeAndShowDialog();
	
	// and now we'll want to actually grab that information from the box
	selectionMethod = Dialog.getChoice();
	chosenOS = Dialog.getChoice();
	useBatchMode = Dialog.getCheckbox();
	shouldShowRoutineErrors = Dialog.getCheckbox();
	shouldDisplayProgress = Dialog.getCheckbox();
	shouldOutputChalkPics = Dialog.getCheckbox();
	shouldOutputFlipped = Dialog.getCheckbox();
	// processed results
	shouldWaitForUserProc = Dialog.getCheckbox();
	shouldOutputAnyResults = Dialog.getCheckbox();
	outputToNewFolderProc = Dialog.getCheckbox();
	newFolderNameProc = Dialog.getString();
	shouldOutputProccessed = Dialog.getCheckbox();
	procResultFilename = Dialog.getString();
	// raw results stuff
	shouldWaitForUserRaw = Dialog.getCheckbox();
	shouldOutputAnyCoords = Dialog.getCheckbox();
	outputToNewFolderRaw = Dialog.getCheckbox();
	newFolderNameRaw = Dialog.getString();
	shouldOutputRawCoords = Dialog.getCheckbox();
	rawCoordFilename = Dialog.getString();
	// processed coords
	outputToNewFolderProcCoord = Dialog.getCheckbox();
	newFolderNameProcCoord = Dialog.getString();
	shouldOutputProcCoords = Dialog.getCheckbox();
	crctCoordsFilename = Dialog.getString();
	Dialog.getCheckbox();
	formCoordsFilename = Dialog.getString();
	// groups
	outputToNewFolderGroups = Dialog.getCheckbox();
	newFolderNameGroups = Dialog.getString();
	shouldOutputGroups = Dialog.getCheckbox();
	rawGroupsFilename = Dialog.getString();
	Dialog.getCheckbox();
	procGroupsFilename = Dialog.getString();
	// save what we just got
	serialize();
	
	// correct some variables based on some other variables
	if(shouldOutputAnyResults == false){
		shouldOutputProcessed = false;
	}//end if we shouldn't output any results
	if(shouldOutputAnyCoords == false){
		shouldOutputRawCoords = false;
		shouldOutputProcCoords =false;
		shouldOutputGroups = false;
	}//end if we shouldn't output any coordinates
}//end if there are not arguments
else{
	// this section kinda just straight up doesn't work right now
	chosenFilePath = arguments;
	useBatchMode = true;
}//end else we do have arguments (we don't really have that set up atm)

// speed up the program a little bit (supposedly 20 times faster)
if(useBatchMode){
	setBatchMode("hide");
}//end if we might as well just enter batch mode

filesToPrc = newArray(0);
chalkPicDir = "";
if(shouldOutputChalkPics == true && selectionMethod != "Directory"){
	showMessage("Unfortunitely chalk picture output is not supported for " +
	"selection methods other than \"Directory\". \nTherefore I'll just " +
	"pretend that you didn't select that, as without Directory selection,\n" +
	"I won't know how to put those pictures in a separate directory...");
	shouldOutputChalkPics = false;
}//end if we don't want to output chalk pics

if(selectionMethod == "Single File"){
	filesToPrc = newArray(1);
	filesToPrc[0] = File.openDialog("Please choose a grid to process");
}//end if we're just processing a single file
else if(selectionMethod == "Multiple Files"){
	numOfFiles = getNumber("How many files would you like to process?", 1);
	filesToPrc = newArray(numOfFiles);
	for(i = 0; i < numOfFiles; i++){
		filesToPrc[i] = File.openDialog("Please choose file " + (i+1) + 
		"/" + (numOfFiles) + ".");
	}//end looping to get all the files we need
}//end if we're processing multiple single files
else if(selectionMethod == "Directory"){
	chosenDirectory = getDirectory("Please choose a directory to process");

	// gets all the filenames in the directory path
	filesToPrc = getValidFilePaths(chosenDirectory, forbiddenStrings);

	// set chalkPicDir since we know what it is
	chalkPicDir = chosenDirectory;
}//end if we're processing an entire directory

// make sure we actually have files to process
if(lengthOf(filesToPrc) <= 0){
	// tell user what happened
	waitForUser("No Files Selected",
	"It seems that you either gave me an empty directory to process " +
	"or just said\n you want to process a number of files less " +
	"than or equal to zero. \n\nWell... okay then. \n\n" + 
	"It's also possible that you have given a directory that only had " + 
	"images in it \nwhich have a forbidden suffix in the name. Images " + 
	"with certain suffixes \nindicating they've already been processed " +
	"are ignored when selecting \nimages in directory mode, as we only " +
	"want unflipped, untouched images here.\n" + 
	"Guess I'll just exit, after saving your settings, of course.");
	// save settings for next time
	// (actually, they've already been saved ¯\_(ツ)_/¯)
	serialize();
	// exit the macro
	exit();
}//end if we don't have any files to process.

// array that will hold names of files we failed to process
failedFilenames = newArray(0);
// initialize stuff for progress bar
prgBarTitle = "[Progress]";
timeBeforeProc = getTime();
if(shouldDisplayProgress){
	run("Text Window...", "name="+ prgBarTitle +"width=70 height=2.5 monospaced");
}//end if we should display progress

for(iijjkk = 0; iijjkk < lengthOf(filesToPrc); iijjkk++){
	if(shouldDisplayProgress){
		// display a progress window thing
		timeElapsed = getTime() - timeBeforeProc;
		timePerFile = timeElapsed / (iijjkk+1);
		eta = timePerFile * (lengthOf(filesToPrc) - iijjkk);
		print(prgBarTitle, "\\Update:" + iijjkk + "/" + lengthOf(filesToPrc) +
		" files have been processed.\n" + "Time Elapsed: " + timeToString(timeElapsed) + 
		" sec.\tETA: " + timeToString(eta) + " sec."); 
	}//end if we should display progress
	// get the file path and start processing
	chosenFilePath = filesToPrc[iijjkk];
	open(chosenFilePath);
	// start getting coordinates of cells
	rawCoordResults = DynamicCoordGetter(shouldWaitForUserRaw);
	rawCoordResultsRowCount = nResults;
	rawCoordResultsColCount = 4;
	// displays options explanation
	if(shouldWaitForUserRaw){
		showMessageWithCancel("Action Required",
		"The raw coordinates array has been saved from the results window.");
	}//end if we should wait for the user
	// save things to where they need to go
	if(shouldOutputRawCoords == true){
		if(shouldWaitForUserRaw){
			showMessageWithCancel("Action Required",
			"We will now save the raw coords file.");
		}//end if we should wait for user
		folderSpecifier = newFolderNameRaw;
		if(outputToNewFolderRaw == false){
			folderSpecifier = false;
		}//end if we don't want a new folder
		// quick fix for renaming files
		fileNameBase = File.getName(chosenFilePath);
		//actually save the coords
		saveRawResultsArray(rawCoordResults,nResults,4,
		chosenFilePath,newArray("BX","BY","Width","Height"),
		folderSpecifier, rawCoordFilename + " - " + fileNameBase);
		if(shouldWaitForUserRaw){
			showMessageWithCancel("Action Required",
			"The raw coords file has been successfully saved.");
		}//end if we should wait for user
	}//end if we should save the raw coords
	
	
	// start processing cell coordinates
	// number of cells in grid
	gridCells = 84;
	// max number of rows in the grid
	maxRows = 15;
	// max length of rows in the grid
	maxRowLen = 6;
	// how close Y needs to be to be in a group
	groupTol = 8;
	// the preferred sizes for coordinate selections
	pCellWidth = 58;
	pCellHeight = 114;
	mmCellWidth = pCellWidth / 11.5; // should be ~5
	mmCellHeight = pCellHeight / 11.5; // should be ~10
	//pre-sort 2d array for coordinates before group selection
	/*preNormalizationSort(rawCoordResults,rawCoordResultsRowCount,
	rawCoordResultsColCount,2);*/
	// delete some duplicates so we have an easier time of things
	veryTempArray = deleteDuplicates(rawCoordResults, rawCoordResultsRowCount,
	rawCoordResultsColCount);
	lengthDiff = (lengthOf(rawCoordResults) - lengthOf(veryTempArray))
	/ rawCoordResultsColCount;
	// initialize 2d array we'll put our coordinates into before group construction
	coordRecord = normalizeCellCount(veryTempArray, rawCoordResultsRowCount - lengthDiff,
	rawCoordResultsColCount);
	if(shouldWaitForUserRaw){
		showMessageWithCancel("Finished Cell Count Normalization",
		"Macro has finished trying to normalize cell count.");
	}//end if we want to wait for the user
	// check that we actually did do our normalization correctly
	if(lengthOf(coordRecord) == 0){
		if(shouldShowRoutineErrors == true){
			showMessageWithCancel("Unfortunately, it seems like the previous error " +
		"isn't something we can solve easily at the moment. As such, I'm going " +
		"\nto skip this grid and move on to the next one. If you want to know " +
		"which grid we're skipping, it's " + File.getName(chosenFilePath) + ".");
		}//end if we want to show a routine error
		failedFilenames = Array.concat(failedFilenames, chosenFilePath);
	}//end if we failed to normalize cell count
	else if(lengthOf(coordRecord) / rawCoordResultsColCount != gridCells){
		if(shouldShowRoutineErrors == true){
			showMessageWithCancel("Cell Count Normalization Failed",
		"It seems we have found too many or too few cells. This happens from time\n" + 
		" to time, but we also run some procedures to correct this. Those procedures\n" +
		" have failed. The file whose path is \n\"" + chosenFilePath + "\"\n will be" + 
		"skipped. \nThere should have been " + gridCells + " cells, but instead we\n" +
		"detected " + lengthOf(coordRecord) + " cells instead. If there are too few\n" +
		"cells, this can be caused by certain tolerance values within the program\n" + 
		"being a little bit off for some outlier images. If there are too many cells\n" +
		", that can be caused by an abundance of seeds which are horizontal and\n" + 
		"splitting their cell in half. We already cut some of them out, but if there\n" +
		"are multiple in the same row, that causes problems.\n\n" + 
		"To automatically skip this file in the future when using directory" + 
		"selection,\n append \"-Skip\" to the name of this file.");
		}//end if we want to show a routine error
		failedFilenames = Array.concat(failedFilenames, chosenFilePath);
	}//end if we have the wrong number of cells STILL
	else{
		// initialize array of groups of coordinate sets
		coordGroups = constructGroups(coordRecord, gridCells,
					rawCoordResultsColCount, maxRows, maxRowLen, groupTol);
		// check that groups went okay
		if(lengthOf(coordGroups) == 0){
			if(shouldShowRoutineErrors == true){
				showMessageWithCancel("It seems something went wrong when constructing" +
			"groups that would have caused an array out of bounds exception. \nAs " +
			"such, I'm going to just skip this grid, which is called " +
			File.getName(chosenFilePath) + ".");
			}//end if we want to show a routine error
			failedFilenames = Array.concat(failedFilenames, chosenFilePath);
		}//end if we need to skip a grid
		else{
			// print out the raw groups if we need to
			if(shouldOutputRawCoords == true){
				printGroups(coordGroups,maxRows,maxRowLen,4,"Raw Groups");
			}//end if we're outputting raw coordinates
			// sort the groups without really touching the flags at all
			sortGroups(coordGroups, maxRows, maxRowLen);
			// reprocess the coordinates so they conform to each other a bit more
			reprocessGroups(coordGroups, maxRows, maxRowLen, 4, mmCellWidth,
			mmCellHeight);
			// print out the re-processed groups if we need to
			if(shouldOutputRawCoords == true){
				printGroups(coordGroups,maxRows,maxRowLen,4,"Re-Processed Groups");
			}//end if we're outputting raw coordinates
			// rows grid, plus newrowflag for each row, plus 1 at the beginning
			formCoordCount = maxRows + (maxRows * maxRowLen) + 1;
			// Puts all the coords from the 3d array into a 2d array with proper flags
			formedCoords = moveTo2d(coordGroups, maxRows, formCoordCount);
			// prints out formatted groups if necessary
			if(shouldOutputRawCoords){
				folderVar = "null";
				if(outputToNewFolderRaw == true){
					folderVar = newFolderNameRaw;
				}//end if we're doing a new folder
				else{
					folderVar = false;
					formPath += rawCoordFilename + ".txt";
				}//end else we're not doing a new folder
				saveRawResultsArray(formedCoords,gridCells,4,chosenFilePath,
				newArray("BX","BY","Width","Height"),folderVar,
				"Formatted Coordinates" + " - " +
				File.getNameWithoutExtension(chosenFilePath));
			}//end if we're outputting raw coordinates
			
			// start processing seed information from each cell
			// clear results thing
			run("Clear Results");
			// threshold for detecting the entire kernel
			lowTH = 60;
			// threshold for detecting the chalky region
			hiTH = 185;
			// size limit for analyzing whole kernel in mm^2
			minSz1 = 4;
			// size limit for analyzing as chalky area
			minSz2 = 1;
			maxSz2 = 35;// amusingly, setting this to 15 is actually too small
			// set line counter, which is a global variable
			currentLine = 0;
			// define all the possible column headers in results
			columns = newArray("Area", "X", "Y", "Perim.", "Major", "Minor",
			"Angle", "Circ.", "AR", "Round", "Solidity");
			
			/* loop through all the coordinates and process them */
			processResults(formedCoords, formCoordCount, 4, lowTH, hiTH, minSz1,
			minSz2, columns, shouldOutputProccessed, outputToNewFolderProc,
			shouldWaitForUserProc, procResultFilename, newFolderNameProc,
			chosenFilePath);
		}//end else we have business as usual
	}//end else we have the right number of cells
}//end looping over all the files we want to process

if(shouldDisplayProgress){
	timeElapsed = getTime() - timeBeforeProc;
	print(prgBarTitle, "\\Update:" + lengthOf(filesToPrc) + "/" + lengthOf(filesToPrc) +
	" files have been processed.\n" + "Time Elapsed: " + timeToString(timeElapsed)
	+ " sec.\tETA: 0 sec."); 
}//end if we should display our progress

if(lengthOf(failedFilenames) > 0){
	// build up our message
	sb = "Unfortunitely, it seems that several files failed to be processed.\n" +
	"This is something I'm still working on, but either way, here are the stats:\n" +
	lengthOf(failedFilenames) + " files out of " + lengthOf(filesToPrc) +
	" were unable to be processed." +
	"I'll go ahead and list them below:\n";
	for(i = 0; i < lengthOf(failedFilenames); i++){
		sb += File.getName(failedFilenames[i]) + " at ";
		sb += File.getDirectory(failedFilenames[i]) + "\n";
	}//end looping over each failed file
	// print this message to a log file
	baseDir = getDirectory("macros");
	baseDir += "Macro-Logs" + File.separator;
	File.makeDirectory(baseDir);
	baseDir += "NS-MacroDriver-FailureLog.txt";
	if(File.exists(baseDir) != true){
		File.close(File.open(baseDir));
	}//end if we need to make the file first
	File.append(buildTime() + "\n" + sb + "\n", baseDir);
	// display our message to the user
	showMessageWithCancel("Failed Files Information",sb);
}//end displaying messages about files which failed.

////////////////// END OF MAIN FUNCTION ///////////////////////
///////////////////////////////////////////////////////////////

///////////////////// MAIN FUNCTIONS //////////////////////////

function timeToString(mSec){
	floater = d2s(mSec, 0);
	floater2 = parseFloat(floater);
	floater3 = floater2 / 1000;
	return floater3;
}//end timeToString()

function buildTime(){
	MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug",
	"Sep","Oct","Nov","Dec");
    DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    TimeString ="Date: "+DayNames[dayOfWeek]+" ";
    if (dayOfMonth<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+"\nTime: ";
    if (hour<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+hour+":";
    if (minute<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+minute+":";
    if (second<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+second;
    return TimeString;
}//end buildTime()

function serialize(){
	// serialization for dialogue stuff
	serializationPath = serializationDirectory();
	fileVar = File.open(serializationPath);
	print(fileVar, "useBatchMode=" + useBatchMode);
	print(fileVar, "selectionMethod=" + selectionMethod);
	print(fileVar, "shouldOutputChalkPics=" + shouldOutputChalkPics);
	print(fileVar, "shouldOutputFlipped=" + shouldOutputFlipped);
	print(fileVar, "shouldShowRoutineErrors=" + shouldShowRoutineErrors);
	print(fileVar, "shouldWaitForUserProc=" + shouldWaitForUserProc);
	print(fileVar, "shouldOutputAnyResults=" + shouldOutputAnyResults);
	print(fileVar, "outputToNewFolderProc=" + outputToNewFolderProc);
	print(fileVar, "newFolderNameProc=" + newFolderNameProc);
	print(fileVar, "shouldOutputProcessed=" + shouldOutputProccessed);
	print(fileVar, "procResultFilename=" + procResultFilename);
	print(fileVar, "shouldWaitForUserRaw=" + shouldWaitForUserRaw);
	print(fileVar, "shouldOutputAnyCoords=" + shouldOutputAnyCoords);
	print(fileVar, "outputToNewFolderRaw=" + outputToNewFolderRaw);
	print(fileVar, "newFolderNameRaw=" + newFolderNameRaw);
	print(fileVar, "shouldOutputRawCoords=" + shouldOutputRawCoords);
	print(fileVar, "rawCoordFilename=" + rawCoordFilename);
	print(fileVar, "outputToNewFolderProcCoord=" + outputToNewFolderProcCoord);
	print(fileVar, "newFolderNameProcCoord=" + newFolderNameProcCoord);
	print(fileVar, "shouldOutputProcCoords=" + shouldOutputProcCoords);
	print(fileVar, "crctCoordsFilename=" + crctCoordsFilename);
	print(fileVar, "formCoordsFilename=" + formCoordsFilename);
	print(fileVar, "outputToNewFolderGroups=" + outputToNewFolderGroups);
	print(fileVar, "newFolderNameGroups=" + newFolderNameGroups);
	print(fileVar, "shouldOutputGroups=" + shouldOutputGroups);
	print(fileVar, "rawGroupsFilename=" + rawGroupsFilename);
	print(fileVar, "procGroupsFilename=" + procGroupsFilename);
	print(fileVar, "shouldDisplayProgress=" + shouldDisplayProgress);
	print(fileVar, "chosenOS=" + chosenOS);
	File.close(fileVar);
}//end serialize()

function deserializeAndShowDialog(){
	// deserialization for dialogue stuff
	// get our file io out of the way
	serializationPath = serializationDirectory();
	// actually do all the parsing stuff
	if(File.exists(serializationPath)){
		fullFile = File.openAsString(serializationPath);
		// get each line of the file
		lines = split(fullFile, "\n");
		if(lengthOf(lines) >= 28){
			// try to get an array of just the data of each line
			justData = newArray();
			for(i = 0; i < lengthOf(lines); i++){
				if(lengthOf(lines[i]) > 1){
					splitLine = split(lines[i], "=");
					if(lengthOf(splitLine) <= 1){
						justData = Array.concat(justData,"");
					}//end if we have blank data here
					else{
						justData = Array.concat(justData,splitLine[1]);
					}//end else we can add as usual
				}//end if we don't have a blank line
			}//end looping to just get data from each line
			// now we can do things by index of justData
			if(lengthOf(justData) > 28){
				useBatchMode = parseInt(justData[0]);
				selectionMethod = justData[1];
				shouldOutputChalkPics = parseInt(justData[2]);
				shouldOutputFlipped = parseInt(justData[3]);
				shouldShowRoutineErrors = parseInt(justData[4]);
				shouldWaitForUserProc = parseInt(justData[5]);
				shouldOutputAnyResults = parseInt(justData[6]);
				outputToNewFolderProc = parseInt(justData[7]);
				newFolderNameProc = justData[8];
				shouldOutputProcessed = parseInt(justData[9]);
				procResultFilename = justData[10];
				shouldWaitForUserRaw = parseInt(justData[11]);
				shouldOutputAnyCoords = parseInt(justData[12]);
				outputTonewFolderRaw = parseInt(justData[13]);
				newFolderNameRaw = justData[14];
				shouldOutputRawCoords = parseInt(justData[15]);
				rawCoordFilename = justData[16];
				outputToNewFolderProcCoord = parseInt(justData[17]);
				newFolderNameProcCoord = justData[18];
				shouldOutputProcCoords = parseInt(justData[19]);
				crctCoordsFilename = justData[20];
				formCoordsFilename = justData[21];
				outputToNewFolderGroups = parseInt(justData[22]);
				newFolderNameGroups = justData[23];
				shouldOutputGroups = parseInt(justData[24]);
				rawGroupsFilename = justData[25];
				procGroupsFilename = justData[26];
				shouldDisplayProgress = parseInt(justData[27]);
				chosenOS = justData[28];
			}//end if we have enough lines
		}//end if we can load data from the file
	}//end if the file exists
	
	
	// some simple little dialogue constants
	strWdt = 25;
	// We'll go ahead and make a fancy dialog box because why not?
	Dialog.createNonBlocking("Macro Options");
	//Dialog.addMessage("Please specify the preferred behavior of the macro.");
	Dialog.addChoice("File Selection Method", selectionMethods, selectionMethod);
	Dialog.addToSameRow();
	Dialog.addChoice("Current Operating System", validOSs, chosenOS);
	Dialog.addCheckboxGroup(2, 3, newArray("Don't Show Images for Better Performance",
	"Show Routine Errors", "Show Progress","Output Chalk Detection Pictures",
	"Output Flipped Image Copies"),newArray(useBatchMode, shouldShowRoutineErrors,
	shouldDisplayProgress,shouldOutputChalkPics,shouldOutputFlipped));
	// stuff for processed results
	Dialog.addMessage("Final Seed Processing");
	Dialog.addCheckbox("Wait For User", shouldWaitForUserProc);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Output Any Results at All", shouldOutputAnyResults)
	Dialog.addCheckbox("Output Results To Folder", outputToNewFolderProc);
	Dialog.addToSameRow();
	Dialog.addString("Optional Folder Name", newFolderNameProc, strWdt);
	Dialog.addCheckbox("Output File of Processed Results",
	shouldOutputProccessed);
	Dialog.addToSameRow();
	Dialog.addString("Results Filename",
	procResultFilename, strWdt);
	// stuff for raw coordinates
	Dialog.addMessage("Raw Coordinate Output Options");
	Dialog.addCheckbox("Wait For User", shouldWaitForUserRaw);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Output any Debugging Coordinates at All", shouldOutputAnyCoords);
	// raw coords
	Dialog.addCheckbox("Output Coordinatess To Folder", outputToNewFolderRaw);
	Dialog.addToSameRow();
	Dialog.addString("Optional Folder Name", newFolderNameRaw, strWdt);
	Dialog.addCheckbox("Output File of Raw Cell Coordinatess",
	shouldOutputRawCoords);
	Dialog.addToSameRow();
	Dialog.addString("Raw Cell Coordinates Filename", rawCoordFilename, strWdt);
	// processed coords
	Dialog.addMessage("Processed Coordinate Output Options");
	Dialog.addCheckbox("Processed Coordinates to Folder", outputToNewFolderProcCoord);
	Dialog.addToSameRow();
	Dialog.addString("Optional Folder Name", newFolderNameProcCoord, strWdt);
	Dialog.addCheckbox("Output Processed Coordinates",shouldOutputProcCoords);
	Dialog.addToSameRow();
	Dialog.addString("Corrected Coordinates Filename", crctCoordsFilename, strWdt);
	Dialog.addCheckbox("",shouldOutputProcCoords);
	Dialog.addToSameRow();
	Dialog.addString("Formatted Coordinates Filename", formCoordsFilename, strWdt);
	// groups
	Dialog.addMessage("Grouped Coordinate Output Options");
	Dialog.addCheckbox("Output Coordinates To Folder", outputToNewFolderGroups);
	Dialog.addToSameRow();
	Dialog.addString("Optional Folder Name", newFolderNameGroups, strWdt);
	Dialog.addCheckbox("Output Raw Grouped Coordinates",shouldOutputGroups);
	Dialog.addToSameRow();
	Dialog.addString("Raw Grouped Coordinate Filename", rawGroupsFilename, strWdt);
	Dialog.addCheckbox("",shouldOutputGroups);
	Dialog.addToSameRow();
	Dialog.addString("Processed Group Coordinate Filename", procGroupsFilename, strWdt);
	// actually show the dialog box
	Dialog.show();
}//end deserialize()

function serializationDirectory(){
	// generates a directory for serialization
	macrDir = getDirectory("macros");
	macrDir += "Macro-Configuration/";
	File.makeDirectory(macrDir);
	macrDir += "MacroDriverConfig.txt";
	return macrDir;
}//end serializationDirectory()

/*
 * returns an array of valid file paths in the specified
 * directory. Any file whose base name contains a string within
 * the forbiddenStrings array will not be added.
 */
function getValidFilePaths(directory, forbiddenStrings){
	// gets array of valid file paths without forbidden strings
	// just all the filenames
	baseFileNames = getAllFilesFromDirectories(newArray(0), directory);
	// just has booleans for each filename
	q = forbiddenStrings;
	boolArray = areFilenamesValid(baseFileNames, q, false);
	// number of valid filenames we found
	correctFileNamesCount = countTruths(boolArray);
	// initialize our new array of valid names
	filenames = newArray(correctFileNamesCount);
	// populate filenames array
	j = 0;
	for(i = 0; i < lengthOf(boolArray) && j < lengthOf(filenames); i++){
		if(boolArray[i] == true){
			filenames[j] = baseFileNames[i];
			j++;
		}//end if we have a truth
	}//end looping for each element of boolArray
	return filenames;
}//end getValidFilePaths(directory)

/*
 * just returns the number of elements in array which are true
 */
function countTruths(array){
	truthCounter = 0;
	for(i = 0; i < lengthOf(array); i++){
		if(array[i] == true){
			truthCounter++;
		}//end if array[i] is a truth
	}//end looping over array
	return truthCounter;
}//end countTruths(array)

/*
 * 
 */
function getAllFilesFromDirectories(filenames, directoryPath){
	// recursively gets all the files from all the subdirectories of specified path
	// get all the files in the specified directory, including subdirectories
	subFiles = getFileList(directoryPath);
	//print("subFiles before:"); Array.print(subFiles);
	// find number of files in subFiles
	filesInDir = 0;
	for(i = 0; i < lengthOf(subFiles); i++){
		// add full path back to name
		subFiles[i] = directoryPath + subFiles[i];
		if(File.isDirectory(subFiles[i]) == false){
			filesInDir++;
		}//end if we found a file
	}//end looping over sub files
	//print("subFiles after:"); Array.print(subFiles);
	// get list of new filenames
	justNewPaths = newArray(filesInDir);
	indexInNewPaths = 0;
	for(i = 0; i < lengthOf(subFiles); i++){
		if(File.isDirectory(subFiles[i]) == false){
			justNewPaths[indexInNewPaths] = subFiles[i];
			indexInNewPaths++;
		}//end if we found a file
	}//end looping over subFiles to get filenames
	// add new filenames to old array
	returnArray = Array.concat(filenames,justNewPaths);
	//print("returnArray before:"); Array.print(returnArray);
	// recursively search all subdirectories
	for(i = 0; i < lengthOf(subFiles); i++){
		if(File.isDirectory(subFiles[i])){
			tempArray = Array.copy(returnArray);
			newFiles = getAllFilesFromDirectories(filenames, subFiles[i]);
			//print("newFiles:"); Array.print(newFiles);
			returnArray = Array.concat(tempArray,newFiles);
			//print("returnArray after:"); Array.print(returnArray);
		}//end if we found a subDirectory
	}//end looping to get all the subDirectories
	return returnArray;
}//end getAllFilesFromDirectories(filenames, directoryPath)

/*
 * Generates an array with true or false depending on whether each
 * filename is valid. Validity is determined by not having any part
 * of the filename including a string in the forbiddenStrings array.
 * If allowDirectory is set to false, then names ending in the file
 * separator will be determined to be invalid. Otherwise, whether
 * a file is a directory or not will be ignored.
 */
function areFilenamesValid(filenames, forbiddenStrings, allowDirectory){
	// returns true false array on whether files are valid
	booleanArray = newArray(lengthOf(filenames));
	// loop to find out which are valid
	for(i = 0; i < lengthOf(filenames); i++){
		// check if filenames[i] is a directory
		if(allowDirectory == false && File.isDirectory(filenames[i])){
			booleanArray[i] = false;
		}//end if this is a subdirectory
		else{
			// loop to look for all the forbidden strings
			foundString = false;
			tempVar = filenames[i];
			fileExtension = substring(tempVar, lastIndexOf(tempVar, "."));
			if(fileExtension != ".tif"){
				booleanArray[i] = false;
			}//end if 
			else{
				filename = File.getName(filenames[i]);
				for(j = 0; j < lengthOf(forbiddenStrings); j++){
					if(indexOf(filename, forbiddenStrings[j]) > -1){
						foundString = true;
						j = lengthOf(forbiddenStrings);
					}//end if we found a forbidden string
				}//end looping over forbiddenStrings
				if(foundString){
					booleanArray[i] = false;
				}//end if we found a forbidden string
				else{
					booleanArray[i] = true;
				}//end else we have a valid file on our hands
			}//end else we need to look for forbidden strings
				
		}//end else it might be good
	}//end looping over each element of baseFileNames
	return booleanArray;
}//end areFilenamesValid(filenames, forbiddenStrings, allowDirectory)

/*
 * Performs the first step of the algorithm, finding all the cell
 * coords. Parameter Explanation: shouldWait specifies whether or
 * not the program will give an explanation to the user as it steps
 * through execution.
 */
function DynamicCoordGetter(shouldWait){
	// gets all the coordinates of the cells
	// save a copy of the image so we don't screw up the original
	makeBackup("coord");
	// horizontally flip the image so we have things alligned properly
	run("Flip Horizontally");
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Image has been flipped");
	}//end if we need to wait
	//save copy of our flipped image if we feel like it
	if(shouldOutputFlipped){
		newPth = File.getDirectory(chosenFilePath);
		newPth += "FlippedImages" + File.separator;
		File.makeDirectory(newPth);
		newPth += File.getNameWithoutExtension(chosenFilePath) + "-F.tif";
		save(newPth);
	}//end if we should output a flipped image
	// Change image to 8-bit grayscale to we can set a threshold
	run("8-bit");
	// set threshold to only detect the cells
	// threshold we set is 0-126 as of 8/12/2021 12:15
	// now it's 0-160 as of 8/31/2021 4:00
	if(chosenOS == validOSs[0]){
		setThreshold(0, 126);
	}//end if we're on Windows 10
	else if(chosenOS == validOSs[1]){
		setThreshold(0, 160);
	}//end else if we're on Windows 7
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Threshold for Cells has been Set");
	}//end if we need to wait
	// set scale so we have the right dimensions
	run("Set Scale...", "distance=11.5 known=1 unit=mm global");
	// set measurements to only calculate what we need(X,Y,Width,Height)
	run("Set Measurements...",
	"bounding redirect=None decimal=1");
	// set particle analysis to only detect the cells as particles
	run("Analyze Particles...", 
	"size=15-Infinity circularity=0.10-1.00 show=[Overlay Masks] " +
	"display exclude clear include");
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Scale and Measurements were set, so now " + 
		"we have detected what cells we can.");
	}//end if we need to wait
	// extract coordinate results from results display
	coordsArray = getCoordinateResults();
	// open the backup
	openBackup("coord", true);
	return coordsArray;
}//end DynamicCoordGetter(shouldWait)

// does not seem to work, so just ignore ig
function preNormalizationSort(array,rcX,rcY,grpTol){
	for(i = 0; i < rcX; i++){
		// set current element as minimum
		mRecX = twoDArrayGet(array,rcX,rcY,i,0);
		mRecY = twoDArrayGet(array,rcX,rcY,i,1);
		mRecInd = i;
		// find actual minimum
		for(j = i+1; j < rcX; j++){
			if(twoDArrayGet(array,rcX,rcY,j,0) < mRecX){
				if(abs(twoDArrayGet(array,rcX,rcY,j,1) - mRecY) <= grpTol){
					mRecX = twoDArrayGet(array,rcX,rcY,j,0);
					mRecY = twoDArrayGet(array,rcX,rcY,j,1);
					mRecInd = j;
				}//end if we found a compatible Y
			}//end if we found a smaller X
		}//end looping to try and find minimum with compatible Y
		// figure out if we need to look again
		if(mRecX == twoDArrayGet(array,rcX,rcY,i,0) && 
		mRecY == twoDArrayGet(array,rcX,rcY,i,1)){
			//find the lowest Y value
			mRecY2 = 9999999;
			mRecX2 = 9999999;
			mRecInd2 = -1;
			for(j = i+1; j < rcX; j++){
				if(abs(twoDArrayGet(array,rcX,rcY,j,1) - mRecY) > grpTol &&
				twoDArrayGet(array,rcX,rcY,j,1) <= mRecY2){
					mRecY2 = twoDArrayGet(array,rcX,rcY,j,1);
					mRecX2 = twoDArrayGet(array,rcX,rcY,j,0);
					mRecInd2 = j;
				}//end if we found a new minimum Y
			}//end looping to find next lowest Y value

			// we should now know the next Y, so now find matching X
			for(j = i+1; j < rcX; j++){
				if(twoDArrayGet(array,rcX,rcY,j,0) < mRecX && 
				twoDArrayGet(array,rcX,rcY,j,1) == mRecY){
					mRecX = twoDArrayGet(array,rcX,rcY,j,0);
					mRecInd = j;
				}//end if we found a new minimum X
			}//end looping to find a new minimum X
		}//end if we didn't find one in the same level

		// either way, now we need to swap mRecInd-th element with i-th element
		twoDArraySwap(array,rcX,rcY,mRecInd,i);
	}//end looping over coords
}//end preNormalizationSort()

function deleteDuplicates(d2Array, xT, yT){
	// deletes elements in 2d array with very similar X and Y, returns new array
	// tolerance for x values closeness
	xTol = 2;
	// tolerance for y values closeness
	yTol = 5;
	Array.print(d2Array);
	// array to hold index of bad coordinates
	badInd = newArray(0);
	// find extremely similar indexes
	for(i = 0; i < xT; i++){
		// Note: might want to exclude processing of bad indexes here
		if(contains(badInd, i) == false){
			// get x and y for i
			d2x = twoDArrayGet(d2Array, xT, yT, i, 0);
			d2y = twoDArrayGet(d2Array, xT, yT, i, 1);
			for(j = i+1; j < xT; j++){
				diffX = abs(d2x - twoDArrayGet(d2Array, xT, yT, j, 0));
				diffY = abs(d2y - twoDArrayGet(d2Array, xT, yT, j, 1));
				if(diffX < xTol && diffY < yTol){
					/*print(twoDArrayGet(d2Array, xT, yT, j, 0));
					print(twoDArrayGet(d2Array, xT, yT, j, 1));
					print(twoDArrayGet(d2Array, xT, yT, j, 2));
					print(twoDArrayGet(d2Array, xT, yT, j, 3));
					waitForUser("diffX:" + diffX + " diffY:" + diffY +
					"\nx:" + d2x + " y:" + d2y);*/
					badInd = Array.concat(badInd,j);
				}//end if this is VERY close to d2Array[i]
			}//end looping all the rest of the array
		}//end if this array is good
	}//end looping over d2Array
	// make array based on learned dimensions
	rnLng = xT - lengthOf(badInd);
	rtnArr = twoDArrayInit(rnLng, yT);
	curRtnInd = 0;
	// add good indices to new array
	for(i = 0; i < xT; i++){
		if(contains(badInd, i) == false){
			x = twoDArrayGet(d2Array, xT, yT, i, 0);
			y = twoDArrayGet(d2Array, xT, yT, i, 1);
			w = twoDArrayGet(d2Array, xT, yT, i, 2);
			h = twoDArrayGet(d2Array, xT, yT, i, 3);
			twoDArraySet(rtnArr, rnLng, yT, curRtnInd, 0, x);
			twoDArraySet(rtnArr, rnLng, yT, curRtnInd, 1, y);
			twoDArraySet(rtnArr, rnLng, yT, curRtnInd, 2, w);
			twoDArraySet(rtnArr, rnLng, yT, curRtnInd, 3, h);
			curRtnInd++;
		}//end if this isn't a bad index
	}//end looping over original array
	return rtnArr;
}//end deleteDuplicates(d2Array, xT, yT)

function contains(array, val){
	foundVal = false;
	for(ijkm = 0; ijkm < lengthOf(array) && foundVal == false; ijkm++){
		if(array[ijkm] == val){
			foundVal = true;
		}//end if we found the value
	}//end looping over array
	return foundVal;
}//end contains

function normalizeCellCount(d2Arr, xT, yT){
	// normalize the cell count of rawCoords to gridCells
	// initialize 2d array we'll put our coordinates into before group construction
	coordRecord = twoDArrayInit(gridCells, 4);
	// check to make sure we have the right number of cells
	if(nResults < gridCells){
		if(shouldShowRoutineErrors == true){
			showMessageWithCancel("Unexpected Cell Number",
		"In the file " + File.getName(chosenFilePath) + ", which is located at \n" +
		chosenFilePath + ", \n" +
		"it seems that we were unable to detect the location of every cell. \n" + 
		"There should be " + gridCells + " cells in the grid, but we have only \n" + 
		"detected " + nResults + " of them. This could be very problematic later on.");
		}//end if we want to show a routine error
		return newArray(0);
	}//end if we haven't detected all the cells we should have
	else if(nResults > gridCells){
		// we'll need to delete extra cells
		curCellCt = nResults;
		// if less than tol, then on same row
		inCelTol = 2.7;// was 1.5
		// if more than tol, then on different row
		outCelTol = 10;
		// current index we're putting stuff into for coordRecord
		curRecInd = 0;
		// set most recent Y by default as first Y
		mRecY = twoDArrayGet(d2Arr,xT,yT,0,1);
		// set most recent difference to 0
		mRecDiff = 0;
		for(i = 0; i < xT; i++){
			// figure out how this Y compares to last one
			thisY = twoDArrayGet(d2Arr,xT,yT,i,1);
			x = twoDArrayGet(d2Arr,xT,yT,i,0);
			w = twoDArrayGet(d2Arr,xT,yT,i,2);
			h = twoDArrayGet(d2Arr,xT,yT,i,3);
			diffFromRec = abs(thisY - mRecY);
			if(diffFromRec < inCelTol || diffFromRec > outCelTol){
				// add this index of rawCoordResults to coordRecord
				a = twoDArraySet(coordRecord,gridCells,4,curRecInd,0,x);
				b = twoDArraySet(coordRecord,gridCells,4,curRecInd,1,thisY);
				c = twoDArraySet(coordRecord,gridCells,4,curRecInd,2,w);
				d = twoDArraySet(coordRecord,gridCells,4,curRecInd,3,h);
				// check that we're in bounds
				if(a == false || b == false || c == false || d == false){
					return newArray(0);
				}//end if we found a problem
				// print something to the log
				print("found a normal cell, indexed to "+curRecInd +
				", diffFromRec of " + diffFromRec);
				// increment curRecInd to account for addition
				curRecInd++;
			}//end if we think differences look normal
			else if(mRecDiff > inCelTol && mRecDiff < outCelTol){
				// add this index of rawCoordResults to coordRecord
				twoDArraySet(coordRecord,gridCells,4,curRecInd,0,x);
				twoDArraySet(coordRecord,gridCells,4,curRecInd,1,thisY);
				twoDArraySet(coordRecord,gridCells,4,curRecInd,2,w);
				twoDArraySet(coordRecord,gridCells,4,curRecInd,3,h);
				// print something to the log
				print("found a bad cell, but it's only bad because of last");
				// increment curRecInd to account for addition
				curRecInd++;
			}//end else if last one was not good, so this one is bad because of that
			else{
				// print something to the log
				print("found the start of a bad cell, not adding it");
			}//end else we found the start of a bad cell

			// set most recent Y again so it's updated for next iteration
			mRecDiff = diffFromRec;
			mRecY = thisY;
		}//end looping over cells in rawCoordResults
		// quick fix for renaming files
		if(shouldOutputRawCoords == true){
			fileNameBase = File.getName(chosenFilePath);
			folderSpecifier = newFolderNameRaw;
			if(outputToNewFolderRaw == false) folderSpecifier = false;
			saveRawResultsArray(coordRecord,gridCells,4,
			chosenFilePath,newArray("BX","BY","Width","Height"),
			folderSpecifier,"Corrected Coordinates - " + fileNameBase);
		}//end if we're outputting a file
	}//end else if there are too many cells
	else{
		// just set coordResult to rawCoordResults
		coordRecord = rawCoordResults;
	}//end else we have the right number of cells
	return coordRecord;
}//end normalizeCellCount()

/*
 * coords2d is the array we want to convert, rcX is the row count of that
 * array, and rcY is the column count of the array. maxRows is the number
 * of rows in in the new 3d array, and maxRowLen is the number of columns
 * in the 3d array. groupTol is used to determine which coordinates should
 * be put within groups, as only items within groupTol of each other can
 * be within a group.
 */
function constructGroups(coords2d,rcX,rcY,maxRows,maxRowLen,groupTol){
	// constructs an unsorted 3d array based off of coords2d
	// initialize array of groups of coordinate sets
	coordGroups = threeDArrayInit(maxRows, maxRowLen, 4);
	// populate group array with default values
	for(i = 0; i < maxRows; i++){
		for(j = 0; j < maxRowLen; j++){
			for(k = 0; k < 4; k++){
				// set values to missing cell flag
				threeDArraySet(coordGroups,maxRowLen,4,i,j,k,-1);
			}//end looping over 3rd dimension
		}//end looping over 2nd dimension
	}//end looping over 1st dimension

	// current index of the group we're building into
	curGroup = 0;
	// current index within our current group to put stuff into next
	curGroupInd = 0;
	// set most recent Y by default as first Y coordinate
	mostRecentY = twoDArrayGet(coords2d, rcX, rcY, 0, 1);
	// try to construct groups
	for(i = 0; i < rcX; i++){
		// save some calculated values for our if statement
		thisY = twoDArrayGet(coords2d, rcX, rcY, i, 1);
		diffFromRec = abs(thisY - mostRecentY);
		// also calculate a few more for easier expressions
		x1 = twoDArrayGet(coords2d, rcX, rcY, i, 0);
		width1 = twoDArrayGet(coords2d, rcX, rcY, i, 2);
		height1 = twoDArrayGet(coords2d, rcX, rcY, i, 3);
	
		// find out if we need to add to a new group
		if(diffFromRec > groupTol){
			curGroup++;
			curGroupInd = 0;
		}//end if this Y is outside tolerance
	
		// put the coordinates in the grouped array in the right group slot
		a = threeDArraySet(coordGroups,maxRowLen,4,curGroup,curGroupInd,0,x1);
		b = threeDArraySet(coordGroups,maxRowLen,4,curGroup,curGroupInd,1,thisY);
		c = threeDArraySet(coordGroups,maxRowLen,4,curGroup,curGroupInd,2,width1);
		d = threeDArraySet(coordGroups,maxRowLen,4,curGroup,curGroupInd,3,
		height1);
		// check that nothing went wrong
		if(a == false || b == false || c == false || d == false){
			return newArray(0);
		}//end if something went wrong
		
		// update various reference variables
		curGroupInd++;
		mostRecentY = thisY;
	}//end looping over coordinates
	return coordGroups;
}//end constructGroups(coords2d, maxRows, maxRowLen)

function printGroups(grps,rcX,rcY,rcZ,filename){
	// print out a 3d array as a bunch of groups
	// get our path stuff over with
	filenameBase = File.getDirectory(chosenFilePath);
	if(outputToNewFolderRaw == false){
		filenameBase += filename;
	}//end if we're not doing folders
	else{
		// build new folder into things
		filenameBase += newFolderNameRaw + File.separator;
		File.makeDirectory(filenameBase);
		// add actual filename
		filenameBase += filename;
	}//end else we are doing folders
	filenameBase += " - " + File.getNameWithoutExtension(chosenFilePath) + ".txt";
	fileVar = File.open(filenameBase);
	// now we can actually start writing to the file
	for(i = 0; i < rcX; i++){
		sb = "Row " + (i+1) + "\n";
		for(j = 0; j < rcY; j++){
			sb += "[BX " + d2s(threeDArrayGet(grps,rcY,rcZ,i,j,0),1) + ", ";
			sb += "BY " + d2s(threeDArrayGet(grps,rcY,rcZ,i,j,1),1) + ", ";
			sb += "Width " + d2s(threeDArrayGet(grps,rcY,rcZ,i,j,2),1) + ", ";
			sb += "Height " + d2s(threeDArrayGet(grps,rcY,rcZ,i,j,3),1) + "]\n";
		}//end looping over coordinates
		print(fileVar, sb);
	}//end looping over groups
	File.close(fileVar);
}//end printGroups(grps,rcZ,rcY,rcX,filename)

function sortGroups(threeDArray, grpCnt, rcY){
	// sort the coordinates within their 3d array
	for(i = 0; i < grpCnt; i++){
		// sets most recent X as first X of first coord in i-th group
		mostRecentX = threeDArrayGet(threeDArray,rcY,4,i,0,0);
		for(j = 0; j < rcY - 1; j++){
			// find the minimum element in unsorted part of this group
			// index (corresponds to j) of minimum that we've found
			grpIndNxt = j;
			// X of coordinate at grpIndNext
			grpIndX = threeDArrayGet(threeDArray,rcY,4,i,grpIndNxt,0);
			for(k = j + 1; k < rcY; k++){
				// X of current coordinate in iteration
				curIndX = threeDArrayGet(threeDArray,rcY,4,i,k,0);
				if(curIndX < grpIndX && curIndX > 0){
					grpIndNxt = k;
					grpIndX = curIndX;
				}//end if we found a new minimum
			}//end looping over each forward coordinate in current group

			// we know know the index of the next minimum
			// so now we'll swap the minimum with the j-th element
			threeDArraySwap(coordGroups,maxRowLen,4,i,j,i,grpIndNxt);
		}//end looping over each coordinate in current group
	}//end looping over each group
	return threeDArray;
}//end sortGroups(threeDArray, grpCnt)

function selectGroup(d3A, aXT, aYT, aZT, aX){
	// returns a 2d array holding the specified froup from d3A
	output = twoDArrayInit(aYT, aZT);
	for(i = 0; i < aYT; i++){
		for(j = 0; j < aZT; j++){
			// grab value from 3d array ...
			val = threeDArrayGet(d3A,aYT,aZT,aX,i,j);
			// ... and drop it into the 2d array
			twoDArraySet(output, aYT, aZT, i, j, val);
		}//end looping within coordinates
	}//end looping over columns
	return output;
}//end selectGroup(d3A, aXT, aYT, aZT, aX)

/*
 * updates a group after you've taken it out as a slice using
 * selectGroup(). Necessary because of the lack of pointers.
 */
function updateGroup(d3A, aXT, aYT, aZT, aX, d2A){
	// updates d3A with the group selection taken from selectGroup()
	for(i = 0; i < aYT; i++){
		for(j = 0; j < aZT; j++){
			// grab value from 2d array ...
			val = twoDArrayGet(d2A, aYT, aZT, i, j);
			// ... and drop it into the 3d array
			threeDArraySet(d3A,aYT,aZT,aX,i,j,val);
		}//end looping within coordinates
	}//end looping within a group
}//end updateGroup(d3A, aXT, aYT, aZT, aX, d2A)

/*
 * resizes the coordinate in the specified 2d array of a single group
 * in order to conform to the given width and height.
 */
function resizeGroup(grp, a2YT, a2ZT, W, H){
	// resizes the coordinates to conform to given width and height
	for(ii = 0; ii < a2YT; ii++){
		// get the coords ready for this one
		xx = twoDArrayGet(grp, a2YT, a2ZT, ii, 0);
		yy = twoDArrayGet(grp, a2YT, a2ZT, ii, 1);
		ww = twoDArrayGet(grp, a2YT, a2ZT, ii, 2);
		hh = twoDArrayGet(grp, a2YT, a2ZT, ii, 3);
		// shrink the this coord if it's too big
		if(ww > W || hh > H){
			shrinkCoord(grp,a2YT,a2ZT,ii,W,H);
		}//end if we need to shrink
		if(ww < W || hh < H){
			growCoord(grp,a2YT,a2ZT,ii,W,H);
		}//end if we need to grow
	}//end looping over each coordinate
}//exx = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 0);

function shrinkCoord(grp,a2YT,a2ZT,a2YI,W,H){
	// shrinks one coordinate to match Width and Height
	diffW = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 2) - W;
	diffH = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 3) - H;
	if(diffW > 0){
		xx = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 0);
		ww = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 2);
		xx += diffW / 2;
		ww -= diffW;
		twoDArraySet(grp,a2YT,a2ZT,a2YI,0,xx);
		twoDArraySet(grp,a2YT,a2ZT,a2YI,2,ww);
		diffW = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 2) - W;
	}//end if difference between widths is greater than 0
	if(diffH > 0){
		yy = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 1);
		hh = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 3);
		yy += diffH / 2;
		hh -= diffH;
		twoDArraySet(grp,a2YT,a2ZT,a2YI,1,yy);
		twoDArraySet(grp,a2YT,a2ZT,a2YI,3,hh);
		diffH = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 3) - H;
	}//end if difference between heights is greater than 0
}//end shrinkCoord(grp,a2YT,a2ZT,a2YI,W,H)

function growCoord(grp,a2YT,a2ZT,a2YI,W,H){
	// grows one coordinate to match width and height
	diffW = W - twoDArrayGet(grp, a2YT, a2ZT, a2YI, 2);
	diffH = H - twoDArrayGet(grp, a2YT, a2ZT, a2YI, 3);
	if(diffW > 0){
		ww = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 2);
		ww += diffW;
		twoDArraySet(grp,a2YT,a2ZT,a2YI,2,ww);
		diffW = W - twoDArrayGet(grp, a2YT, a2ZT, a2YI, 2);
	}//end if difference between widths is greater than 0
	if(diffH > 0){
		hh = twoDArrayGet(grp, a2YT, a2ZT, a2YI, 3);
		hh += diffH;
		twoDArraySet(grp,a2YT,a2ZT,a2YI,3,hh);
		diffH = H - twoDArrayGet(grp, a2YT, a2ZT, a2YI, 3);
	}//end if difference between heights is greater than 0
}//end growCoord(grp,a2YT,a2ZT,a2YI,W,H)

function reprocessGroups(d3Arr, arrXT, arrYT, arrZT, W, H){
	// reprocesses groups so the values line up a bit better
	for(i = 0; i < arrXT; i++){
		// grabs the group as a 2d array so it's easier to handle
		tGrp = selectGroup(d3Arr, arrXT, arrYT, arrZT, i);
		// send the group over to be processed
		resizeGroup(tGrp, arrYT, arrZT, W, H);
		// send those new changes back over to the 3d array
		updateGroup(d3Arr, arrXT, arrYT, arrZT, i, tGrp);
	}//end looping over groups
}//end reprocessGroups(d3Arr,arrXT,arrYT,arrZT)

/*
 * Puts all the coords from threeDArray back into a 2d array with
 * the necessary flags added as part of the middle processing step.
 */
function moveTo2d(threeDArray, grpCnt, formCoordCount){
	// Puts all the coords from the 3d array into a 2d array
	// 2d array of stuff
	formCoords = twoDArrayInit(formCoordCount, 4);
	// set last element as newrow flag
	twoDArraySet(formCoords, formCoordCount, 4, formCoordCount-1, 0,-2);
	twoDArraySet(formCoords, formCoordCount, 4, formCoordCount-1, 1,-2);
	twoDArraySet(formCoords, formCoordCount, 4, formCoordCount-1, 2,-2);
	twoDArraySet(formCoords, formCoordCount, 4, formCoordCount-1, 3,-2);
	// initialize some counter variable
		// current group we're working on
		curGroup = 0;
		// index of the current group we're working on
		curGroupInd = 0;
		// current index of formCoords that we can next put something into
		cur2dInd = 0;
	// loop over the groups
	for(i = 0; i < grpCnt; i++){
		//adds newLine flag to our 2darray
		twoDArraySet(formCoords,formCoordCount,4,cur2dInd,0,-2);
		twoDArraySet(formCoords,formCoordCount,4,cur2dInd,1,-2);
		twoDArraySet(formCoords,formCoordCount,4,cur2dInd,2,-2);
		twoDArraySet(formCoords,formCoordCount,4,cur2dInd,3,-2);
		//increment formCoords index reference to account for newrowflag
		cur2dInd++;
		
		// gets the x of fifth coordinate in i-th group
		arbFlagVar = threeDArrayGet(threeDArray,maxRowLen,4,i,4,0);
		if(arbFlagVar != -1){
		   /*
			* we just need to loop over the cells in this group,
			* adding each of them to the 2d array
			*/
			for(j = 0; j < maxRowLen; j++){
				for(k = 0; k < 4; k++){
					// get the proper value
					crdVl = threeDArrayGet(threeDArray,maxRowLen,4,i,j,k);
					// set the proper value
					twoDArraySet(formCoords,formCoordCount,4,cur2dInd,k,
					crdVl);
				}//end looping through coordinate information for one coord
				// increment reference counter
				cur2dInd++;
			}//end looping over the i-th group
		}//end if we have a group of six
		else{
		   /*
			* we need an empty cell, followed by the four
			* detected cells, followed by an empty cell
			*/
			// add in an empty cell
			// adds emptycell flag to our 2darray
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,0,-1);
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,1,-1);
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,2,-1);
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,3,-1);
			// increment formCoords index reference to account for flag
			cur2dInd++;
			// now we need to loop over the four
			for(j = 0; j < maxRowLen-2; j++){
				for(k = 0; k < 4; k++){
					// get the proper value
					crdVl = threeDArrayGet(threeDArray,maxRowLen,4,i,j,k);
					// set the proper value
					twoDArraySet(formCoords,formCoordCount,4,cur2dInd,k,
					crdVl);
				}//end looping through coordinate information for one coord
				// increment reference counter
				cur2dInd++;
			}//end looping over the i-th group
			// adds emptycell flag to our 2darray
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,0,-1);
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,1,-1);
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,2,-1);
			twoDArraySet(formCoords,formCoordCount,4,cur2dInd,3,-1);
			// increment reference counter
			cur2dInd++;
		}//end else we have a group of four
	}//end looping over the groups
	// return the final 2d array
	return formCoords;
}//end moveTo2d(threeDArray)

/*
 * 
 */
function processKernel(X,Y,W,H,windowPattern,shouldWait,fileVar){
	// make a selection and process the kernel

	// make our selection, multiplying in order to convert to pixels from mm
	makeRectangle(X * 11.5, Y * 11.5,
	W * 11.5, H * 11.5);
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Selection Made");
	}//end if we should wait
	// make a copy to work with
	// get a little debugging info first
	
	run("Duplicate...", "title=[" + windowPattern + "]");
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Selection Duplicated");
	}//end if we should wait
	// take a snapshot so we can reset later
	makeBackup("Dup");
	// set which things should be measured
	run("Set Measurements...",
	"area centroid perimeter fit shape redirect=None decimal=2");
	// set the threshold
	run("8-bit");
	setAutoThreshold("Default dark");
	setThreshold(lowTH, 255);
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Kernel Threshold Set");
	}//end if we should wait
	resultsBefore = nResults;
	// analyze particles
	run("Analyze Particles...",
	"size=minSz1-maxSz2 circularity=0.1-1.00" + 
	" show=[Overlay Masks] display");
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Kernel Particles Analyzed");
	}//end if we should wait
	resultsAfter = nResults;
	if(resultsAfter - resultsBefore > 0){
		// print kernel results over the log
		kernelStuff = getAllResults(columns);
		kernelForLog = newArray(lengthOf(columns));
		kCount = lengthOf(kernelForLog);
		for(j = 0; j < kCount; j++){
			kernelForLog[j] = twoDArrayGet(kernelStuff,
			lengthOf(kernelStuff)/lengthOf(columns),
			lengthOf(columns), nResults-1, j);
		}//end looping over all the columns of this line
		currentLine++;
		print(currentLine + "     " + dATS(1, kernelForLog, "     "));
		if(fileVar != false){
			print(fileVar, currentLine + "\t" + dATS(1, kernelForLog, "\t"));
		}//end if we're doing a file
		if(shouldWait){
			showMessageWithCancel("Action Required",
			"Kernel Results Printed");
		}//end if we should wait
	}//end if we detected a kernel
}//end processKernel(x,y,width,height)

/*
 * 
 */
function processChalk(windowPattern, shouldWait, fileVar){
	// process the duplicate for chalk
	
	// reset our copy so we can get chalk
	close(windowPattern);
	openBackup("Dup", false);
	rename(windowPattern);
	// set which things should be measured
	run("Set Measurements...",
	"area centroid perimeter fit shape redirect=None decimal=2");
	// try to smooth image and trim tips
	run("Subtract Background...", "rolling=5 create");
	// set the threshold for the chalk
	run("8-bit");
	setAutoThreshold("Default dark");
	setThreshold(hiTH, 255);
	if(shouldWait){
		showMessageWithCancel("Action Required",
		"Chalk Threshold Set");
	}//end if we should wait	
	// analyze particles
	resultNumBefore = nResults;
	run("Analyze Particles...",
	"size=minSz2-maxSz2 circularity=0.1-1.00" + 
	" show=[Overlay Masks] display");
	if(shouldWait){
		showMessageWithCancel("Action Required", 
		"Chalk Particles Analyzed");
	}//end if we should wait
	if(shouldOutputChalkPics){
		// folder directory for our files to go in
		chalkDir = getChalkPicPath(chosenDirectory, chosenFilePath,
		File.getName(chosenFilePath));
		// figure out what we want to name our file
		chalkPicNm = chalkNames[chalkCounter] + ".tif";
		// flatten image to keep overlays
		run("Flatten");
		// hopefully save the image
		save(chalkDir + chalkPicNm);
		// close the image we just saved to prevent ROI problems
		close();
	}//end if we're outputting chalk pics
	// print chalk results to the log if there are any
	chalkStuff = getAllResults(columns);
	resultNumAfter = nResults;
	if(resultNumBefore != resultNumAfter){
		chalkRowT = resultNumAfter - resultNumBefore;
		chalkColT = lengthOf(columns);
		chalkForLog = twoDArrayInit(chalkRowT,chalkColT);
		// put all the recent chalk data into chalkForLog
		for(jj = 0; jj < chalkRowT; jj++){
			currentLine++;
			sb1 = "" + currentLine + "     ";
			sb2 = "" + currentLine + "\t";
			for(kk = 0; kk < chalkColT; kk++){
				// put right data into chalkForLog
				twoDArraySet(chalkForLog,chalkRowT,chalkColT,jj,kk,
				twoDArrayGet(chalkStuff,lengthOf(chalkStuff) /
				lengthOf(columns), lengthOf(columns), resultNumBefore
				 + jj, kk));
				// add stuff to be put in log or printed
				val = twoDArrayGet(chalkForLog,chalkRowT,chalkColT,jj,kk);
				sb1 += d2s(val, 1) + "     ";
				if(fileVar != false) sb2 += d2s(val, 1) + "\t";
			}//end looping through data for this particle
			// print that stuff out if we need to do so
			print(sb1);
			if(fileVar != false){
				print(fileVar, sb2);
			}//end if we're print stuff to a file
			if(shouldWait){
				showMessageWithCancel("Action Required",
				"Chalk Results Printed to Log");
			}//end if we should wait
		}//end looping over each particle detected
	}//end if we detected something
}//end processChalk(windowPattern)

function getChalkPicPath(directory, imgPath, fldrName){
	// gets the path that the chalk pictures for an image should be writ to
	imgLclDir = File.getDirectory(imgPath);
	dirPar = File.getParent(directory);
	imgDirPar = substring(imgPath,lengthOf(dirPar));
	imgDirChld = substring(imgLclDir, lengthOf(dirPar), lengthOf(imgLclDir));
	nwDir = dirPar + File.separator + "Chalk-Pictures" + imgDirChld;
	nwDir += fldrName + File.separator;
	recursiveMakeDirectory(nwDir);
	return nwDir;
}//end getChalkPicPath

function recursiveMakeDirectory(directory){
	// makes directory even if it has to make multiple directories
	if(directory != 0){
		recursiveMakeDirectory(File.getParent(directory));
	}//end if we can go ahead and recurse
	File.makeDirectory(directory);
}//end recursiveMakeDirectory(directory)

/*
 * 
 */
function processResults(fm2dCrd,x,y,lT,hT,mS1,mS2,col,f1,f2,wFP,fn1,fn2,od){
	// set the scale
	run("Set Scale...", "distance=11.5 known=1 unit=mm global");
	// save a copy of the image so we don't mess up the original
	makeBackup("resultProcess");
	// flip the image horizontally
	run("Flip Horizontally");
	// clear the log
	print("\\Clear");;

	// quick fix for renaming files
	fileBase = File.getName(od);
	fn1 += " - " + fileBase;
	
	// set up stuff for the file
	outputFileVar = false;
	if(f1 == true){
		if(f2 == true){
			// get the base directory of the file we already have
			baseDir = File.getDirectory(od);
			// build the new directory
			newDir = baseDir + fn2;
			// build the new filename
			newName = newDir + File.separator + fn1 + ".txt";
			// make sure the folder actually exists
			File.makeDirectory(newDir + File.separator);
			// get our file variable figured out
			outputFileVar = File.open(newName);
		}//end if we should output to a new folder
		else{
			// get the directory of the file we're proccing
			baseDir = File.getDirectory(od);
			// build the new filename from that directory
			newName = baseDir + File.separator + fn1 + ".txt";
			// get our file variable figured out
			outputFileVar = File.open(newName);
		}//end else we can just drop it in the old folder
	}//end if we should output a file of processed stuff
	
	// make the header
	sb = "\t"; sb1 = "       ";
	for(i = 0; i < lengthOf(col); i++){
		sb += col[i] + "\t";
		sb1 += col[i] + "    ";
	}//end looping for each column
	// output headers to log
	print(sb1);
	// output headers to file (if we want to)
	if(outputFileVar != false){
		print(outputFileVar, sb);
	}//end if we're outputting a file

	// helpful counter for later
	chalkCounter = 0;
	
	for(i = 0; i < x; i++){
		// check for flags
		if(isMissingCellFlag(fm2dCrd,x,y,i,0) == true){
			if(wFP){
				showMessageWithCancel("Action Required",
				"Found Missing Cell Flag");
			}//end if we should wait
			// add cell start
			currentLine++;
			startFlag = CellStartFlag(11);
			if(f1){
				print(outputFileVar, currentLine + "\t"
				+ dATS(1, startFlag, "\t"));
			}//end if we're outputting to the files
			print(currentLine + "     " + dATS(1, startFlag, "     "));
			// add the cell end
			currentLine++;
			endFlag = CellEndFlag(11);
			if(f1){
				print(outputFileVar, currentLine + "\t" +
				dATS(1, endFlag, "\t"));
			}//end if we're outputting to the files
			print(currentLine + "     " + dATS(1, endFlag, "     "));
		}//end if we have a missing cell flag
		else if(isNewRowFlag(fm2dCrd,x,y,i,0) == true){
			if(wFP){
				showMessageWithCancel("Action Required",
				"Found New Row Flag");
			}//end if we should wait
			// new row flag
			currentLine++;
			rowFlag = NewRowFlag(11);
			if(f1){
				print(outputFileVar,currentLine + "\t" +
				dATS(1, rowFlag, "\t"));
			}//end if we're outputting files
			print(currentLine + "     " + dATS(1, rowFlag, "     "));
		}//end else if we have a new row flag
		else{
			// the bounding X for this cell
			thisBX = twoDArrayGet(fm2dCrd, x, y, i, 0);
			// the bounding Y for this cell
			thisBY = twoDArrayGet(fm2dCrd, x, y, i, 1);
			// the bounding width for this cell
			thisWidth = twoDArrayGet(fm2dCrd, x, y, i, 2);
			// the bounding height for this cell
			thisHeight = twoDArrayGet(fm2dCrd, x, y, i, 3);

			if(wFP){
				showMessageWithCancel("Action Required",
				"Coordinates Recieved");
			}//end if we should wait

			currentLine++;

			// add cell start
			startFlag = CellStartFlag(11);
			if(f1){
				print(outputFileVar, currentLine + "\t"
				+ dATS(1, startFlag, "\t"));
			}//end if we're outputting to the files
			print(currentLine + "     " + dATS(1, startFlag, "     "));
	
			// set the pattern for the window
			windowPattern = "temporary duplicate";
	
			// process the kernel
			processKernel(thisBX, thisBY, thisWidth,
			thisHeight, windowPattern, wFP, outputFileVar);
	
			// process the chalk
			processChalk(windowPattern, wFP, outputFileVar);
			// increment chalk counter
			chalkCounter++;
	
			// add the cell end
			currentLine++;
			endFlag = CellEndFlag(11);
			if(f1){
				print(outputFileVar, currentLine + "\t" +
				dATS(1, endFlag, "\t"));
			}//end if we're outputting to the files
			print(currentLine + "     " + dATS(1, endFlag, "     "));
			// close this duplicate
			close(windowPattern);
			if(wFP){
				waitForUser("Action Required", "Duplcate Closed");
			}//end if we should wait
		}//end else we do things normally
	}//end looping over coordinates

	if(f1 == true){
		File.close(outputFileVar);
	}//end if we need to close our file variable so we don't screw up the file
}//end processResults(fm2dCrd,x,y,lT,hT,mS1,mS2,col,f1,f2,wFP,fn1,fn2,od)

function isMissingCellFlag(d2A,xT,yT,x,y){
	// -1
	val = twoDArrayGet(d2A,xT,yT,x,y);
	if(val == -1) return true;
	else return false;
}//end 

function isNewRowFlag(d2A,xT,yT,x,y){
	// -2
	val = twoDArrayGet(d2A,xT,yT,x,y);
	if(val == -2) return true;
	else return false;
}//end 

/*
 * returns an array as a string
 */
function ArrayToString(array){
	return String.join(array, "");
}//end ArrayToString(array)

function dATS(n, a, c){
	// a is array, n is number of decimals, array to string
	outputString = "";
	for(i = 0; i < lengthOf(a); i++){
		outputString += d2s(a[i], n) + c;
	}//end looping over a
	return outputString;
}//end dATS(n, a)

////////////////// EXTRA FUNCTIONS ////////////////////////////

/*
 * 
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
 * 
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

/*
 * Gets all the info from the results window, storing it
 * in a 2d array. the columns argument should be the name of
 * all the columns in the results window
 */
function getAllResults(columns){
	// gets info from results window, storing it in 2d array
	rowNum = nResults;
	colNum = lengthOf(columns);
	// initialize output 2d array
	output = twoDArrayInit(rowNum, colNum);
	for(i = 0; i < rowNum; i++){
		for(j = 0; j < colNum; j++){
			twoDArraySet(output, rowNum, colNum,
			i, j, getResult(columns[j], i));
		}//end looping through each column
	}//end looping through each row
	
	return output;
}//end getAllResults(columns)

/*
 * This function returns a 2d array of coordinates for all the particles
 * detected in particle analysis or whatever else. It needs to be able
 * to access the X, Y, Width, and Height columns from the results 
 * diplay, so please make sure to set those properly with Set
 * Measurements. Returns the coordinates in the order of X, Y, Width,
 * and Height, with the "row" index of the 2d array accessing a
 * particular coordinate, and the "column" index of the array accessing
 * a particular feature (X, Y, Width, or Height) of that coordinate.
 * It should be noted that the number of rows will be nResults and the
 * number of columns 4 for the array returned.
 */
function getCoordinateResults(){
	// gets coordinate results from results windows. Need bound rect
	// save result columns we want
	coordCols = newArray("BX","BY","Width","Height");
	// first dimension length
	rowNum = nResults;
	// second dimension length
	colNum = lengthOf(coordCols);
	// initialize 2d array
	coords = twoDArrayInit(rowNum, colNum);
	// populate array with data
	for(i = 0; i < rowNum; i++){
		for(j = 0; j < colNum; j++){
			twoDArraySet(coords, rowNum, colNum, i, j,
			getResult(coordCols[j], i));
		}//end looping through coord props
	}//end looping through each coord
	return coords;
}//end getCoordinateResults()

/*
 * saves the data results to the specified path
 */
function saveDataResultsArray(resultsArray, rowT, colT, path, columns){
	// saves data results to specified path
	fileVar = File.open(path);
	// print columns
	rowToPrint = "\t";
	for(i = 0; i < lengthOf(columns); i++){
		rowToPrint += columns[i] + "\t";
	}//end looping over column headers
	print(fileVar, rowToPrint);
	// print array contents
	for(i = 0; i < rowT; i++){
		rowToPrint = "" + (i+1) + "\t";
		for(j = 0; j < colT; j++){
			thisInd = twoDArrayGet(resultsArray, rowT, colT, i, j);
			rowToPrint = rowToPrint + d2s(thisInd, 2) + "\t";
		}//end looping over columns
		print(fileVar, rowToPrint);
	}//end looping over rows
	File.close(fileVar);
}//end saveDataResultsArray(resultsArray, rowT, colT, path)

/*
 * saves an array to a file. is more generic than saveDataResultsArray.
 * Parameter explanation: array=the array you want to save; rowT=the
 * length of the array's first dimension; colT=the length of the array's
 * second dimension; path=the path of your original image; headers=the
 * headers to display above the rows and columns; folder=whether or not
 * you want to save stuff in a new folder. This should be false or empty
 * if you don't want a new folder, or otherwise the name of the folder
 * you want to save stuff to; name=the name of the file you want
 * to save. Make sure this is a valid filename from the start, but
 * don't include the extension
 */
function saveRawResultsArray(array,rowT,colT,path,headers,folder,name){
	// saves array to specified path with other specifications
	// initialize variable for the file stream
	fileVar = saveRawResultsArrayIOHelper(path, folder, name);
	// print columns
	rowToPrint = "\t";
	for(i = 0; i < lengthOf(headers); i++){
		rowToPrint += headers[i] + "\t";
	}//end looping over column headers
	print(fileVar, rowToPrint);
	// print array contents
	for(i = 0; i < rowT; i++){
		rowToPrint = "" + (i+1) + "\t";
		for(j = 0; j < colT; j++){
			// value at this element
			thisInd = twoDArrayGet(array,rowT,colT,i,j);
			rowToPrint = rowToPrint + d2s(thisInd, 2) + "\t";
		}//end looping over columns
		print(fileVar, rowToPrint);
	}//end looping over rows
	File.close(fileVar);
}//end saveRawResultsArray(array,rowT,colT,path,headers,folder,name)

/*
 * Helper method for saveRawResultsArray()
 */
function saveRawResultsArrayIOHelper(path, folder, name){
	// helper method for saveRawResultsArray
	// figure out our folder schenanigans
	if(folder != false && folder != ""){
		// base directory of the open file
		print("path:"); print(path);
		baseDirectory = File.getDirectory(path);
		// create path of new subdirectory
		baseDirectory += folder;
		print("base directory:"); print(baseDirectory);
		// make sure directory exists
		File.makeDirectory(baseDirectory);
		// add full filename to our new path
		baseDirectory = baseDirectory + File.separator;
		if(name == "" || lengthOf(name) <= 0){
			enteredName = saveRawResultsArrayIOHelperDialogHelper();
			baseDirectory = baseDirectory + enteredName + ".txt";
		}//end if we need to get a name from the user!
		else{
			baseDirectory = baseDirectory + name + ".txt";
			print("name:"); print(name);
			print("base directory:"); print(baseDirectory);
		}//end else we can proceed as normal
		// get the file variable and return it
		return File.open(baseDirectory);
	}//end if we're doing a new folder
	else{
		// base directory of the file
		fileBase = substring(path, 0,
		lastIndexOf(path, File.separator));
		// add separator if it was cut off
		if(endsWith(fileBase, File.separator) == false){
			fileBase += File.separator;
		}//end if we need to add separator back
		// get new name of the new file
		resultFilename = name;
		if(name == "" || lengthOf(name) <= 0){
			resultFilename = saveRawResultsArrayIOHelperDialogHelper();
		}//end if we need to get a new name from the user!
		return File.open(fileBase + resultFilename + ".txt");
	}//end else we don't need to mess with folders
}//end saveRawResultsArrayIOHelper(path, folder, name)

/*
 * A helper method for a helper method
 */
function saveRawResultsArrayIOHelperDialogHelper(){
	// a helper method for saveRawResultsArrayIOHelper
	Dialog.create("Enter File Name");
	Dialog.addMessage(
	"It seems that at an earlier point in this programs execution, \n" +
	"you entered a filename that was either invalid or improperly \n" +
	"passed. Please enter a plain filename without a path or file \n" +
	"extension here, so that I can save it properly.");
	Dialog.addString("Filename:", "log");
	Dialog.show();
	return Dialog.getString();
}//end saveRawResultsArrayIOHelperDialogHelper()

/*
 * Sets a value in a 2d array
 */
function twoDArraySet(array, rowT, colT, rowI, colI, value){
	// sets a value in a 2d array
	if((colT * rowI + colI) >= lengthOf(array)){
		return false;
	}//end if we are out of bounds
	else{
		array[colT * rowI + colI] = value;
		return true;
	}//end else we're fine to do stuff
}//end twoDArraySet(array, rowT, colT, rowI, colI, value)

/*
 * gets a value from a 2d array
 */
function twoDArrayGet(array, rowT, colT, rowI, colI){
	// gets a value from a 2d array
	return array[colT * rowI + colI];
}//end twoDArrayGet(array, rowT, colT, rowI, colI)
 
/*
 * creates a 2d array
 */
function twoDArrayInit(rowT, colT){
	// creates a 2d array
	return newArray(rowT * colT);
}//end twoDArrayInit(rowT, colT)

function twoDArraySwap(array,rowT,colT,rI1,rI2){
	tempArray = newArray(colT);
	for(ijk = 0; ijk < colT; ijk++){
		tempArray[ijk] = twoDArrayGet(array,rowT,colT,rI1,ijk);
		rIV = twoDArrayGet(array,rowT,colT,rI2,ijk);
		twoDArraySet(array,rowT,colT,rI1,ijk,rIV);
		twoDArraySet(array,rowT,colT,rI2,ijk,tempArray[ijk]);
	}//end looping over stuff
}//end twoDArraySwap(array,rowT,colT,rI1,rI2)

/*
 * sets a value in a 3d array
 */
function threeDArraySet(array,yT,zT,x,y,z,val){
	// sets a value in a 3d array
	if((x * yT * zT + y * zT + z) >= lengthOf(array)){
		return false;
	}//end if out of bounds
	else{
		array[x * yT * zT + y * zT + z] = val;
		return true;
	}//end else we did fine.
}//end threeDArraySet(array,xT,yT,zT,x,y,z,val)

/*
 * gets a value from a 3d array
 */
function threeDArrayGet(array,yT,zT,x,y,z){
	// gets a value from a 3d array
	return array[x * yT * zT + y * zT + z];
}//end threeDArrayGet(array,xT,yT,zT,x,y,z)

/*
 * creates a 3d array
 */
function threeDArrayInit(xT, yT, zT){
	// creates a 3d array
	return newArray(xT * yT * zT);
}//end threeDArrayInit(xT, yT, zT)

/*
 * swaps two indices of a 3d array
 */
function threeDArraySwap(array,yT,zT,x1,y1,z1,x2,y2,z2){
	// swaps two indices of a 3d array
	arbitraryTempNewVarName1 = threeDArrayGet(array,yT,zT,x1,y1,z1);
	arbitraryTempNewVarName2 = threeDArrayGet(array,yT,zT,x2,y2,z2);
	threeDArraySet(array,yT,zT,x2,y2,z2,arbitraryTempNewVarName1);
	threeDArraySet(array,yT,zT,x1,y1,z1,arbitraryTempNewVarName2);
}//end threeDArraySwap(array,yT,zT,x1,y1,z1,x2,y2,z2)

/*
 * swaps two parts of a 3d array
 */
function threeDArraySwap(array,yT,zT,x1,y1,x2,y2){
	// swaps two parts of a 3d array
	// initialize arrays of what we've got
	index1 = newArray(zT);
	index2 = newArray(zT);
	// figure out values and swap them
	for(qq = 0; qq < zT; qq++){
		arbitraryTempNewVarName1 = threeDArrayGet(array,yT,zT,x1,y1,qq);
		arbitraryTempNewVarName2 = threeDArrayGet(array,yT,zT,x2,y2,qq);
		threeDArraySet(array,yT,zT,x2,y2,qq,arbitraryTempNewVarName1);
		threeDArraySet(array,yT,zT,x1,y1,qq,arbitraryTempNewVarName2);
	}//end creating array from z
}//end threeDArraySwap(array,yT,zT,x1,y1,x2,y2)

/*
 * Just returns an array that represents a new row flag. cols is 
 * the number of columns to include in the flag. It won't work 
 * if you don't have at least one column for the area. 
 * Recommended is 11
 */
function NewRowFlag(cols){
	// 121.0
	flagVals = newArray(121.0, 4.3,
	7.0, 45.0, 9.8, 90, 0.8, 1.6, 0.6, 1.0);
	size = cols;
	if(size < 1) size = 11;
	newRowFlag = newArray(cols);
	for(i = 0; i < cols && i < lengthOf(flagVals); i++){
		newRowFlag[i] = flagVals[i];
	}//end adding each arbitrary data point
	if(size > lengthOf(flagVals)){
		for(i = cols; i < lengthOf(newRowFlag); i++){
			newRowFlag[i] = "121.0";
		}//end looping over next indices of thing
	}//end if we don't have enough values
	return newRowFlag;
}//end NewRowFlag(cols)

/*
 * see NewRowFlag
 */
function CellStartFlag(cols){
	// 81.7
	flagVals = newArray(81.7, 3.5, 5.9, 37.2, 13.2, 7.8, 90.0, 0.7,
	1.7, 0.6, 1.0);
	size = cols;
	if(size < 1) size = 11;
	cellStartFlag = newArray(cols);
	cellStartFlag[0] = "81.7";
	for(i = 0; i < cols && i < lengthOf(flagVals); i++){
		cellStartFlag[i] = flagVals[i];
	}//end adding each arbitrary data point
	if(size > lengthOf(flagVals)){
		for(i = cols; i < lengthOf(cellStartFlag); i++){
			cellStartFlag[i] = "81.7";
		}//end looping over next indices of thing
	}//end if we don't have enough values
	return cellStartFlag;
}//end CellStartFlag(cols)

/*
 * see NewRowFlag
 */
function CellEndFlag(cols){
	// 95.3
	flagVals = newArray(95.3, 3.9, 6.1, 39.8, 13.7, 8.8, 90.0, 0.8,
	1.6, 0.6, 1.0);
	size = cols;
	if(size < 1) size = 11;
	cellEndFlag = newArray(cols);
	cellEndFlag[0] = "95.3";
	for(i = 1; i < cols && i < lengthOf(flagVals); i++){
		cellEndFlag[i] = flagVals[i];
	}//end adding each arbitrary data point
	if(size > lengthOf(flagVals)){
		for(i = cols; i < lengthOf(cellEndFlag); i++){
			cellEndFlag[i] = "95.3";
		}//end looping over next indices of thing
	}//end if we don't have enough values
	return cellEndFlag;
}//end CellEndFlag(cols)

/*
 * prints an array out to a file
 */
function debugPrintArray(d3A, xA, yA, zA, name){
	// build the file directory
	fDir = File.getDirectory(chosenFilePath) + name + ".txt";
	// open up the file
	fileVar = File.open(fDir);
	// loop over everything to print to the file
	for(i = 0; i < xA; i++){
		sb1 = "Row " + (i+1) + "\n";
		for(j = 0; j < yA; j++){
			sb2 = "[";
			for(k = 0; k < zA; k++){
				n = threeDArrayGet(d3A,yA,zA,i,j,k);
				sb2 += d2s(n, 1);
				if(k < zA - 1) sb2 += ", ";
			}//end looping within coords
			sb2 += "]";
			if(j < yA - 1) sb2 += ", \n";
			sb1 += sb2;
		}//end looping within groups
		if(i < xA - 1) sb1 += " \n";
		print(fileVar, sb1);
	}//end looping over groups
	File.close(fileVar);
}//end debugPrintArray(d3A, xA, yA, zA, name)

////////////////////// END OF EXTRA FUNCTIONS /////////////////
////////////////////// END OF PROGRAM DIALOG  /////////////////

// exit out of batch mode
if(useBatchMode){
	setBatchMode("exit and display");
}//end if we might as well just enter batch mode

//wait for user before closing stuff
if(arguments == ""){
	waitForUser("Program Completion Reached",
	"Macro will terminate after this message box has been closed.");
}//end if there are no arguments
run("Close All");
run("Clear Results");
if(isOpen("Results")){selectWindow("Results"); run("Close");}
if(isOpen("Log")){selectWindow("Log"); run("Close");}
if(shouldDisplayProgress){print(prgBarTitle,"\\Close");}
close("*");
doCommand("Close All");