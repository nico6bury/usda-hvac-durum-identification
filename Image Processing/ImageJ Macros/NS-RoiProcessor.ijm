/*
 * Author: Nicholas Sixbury
 * File: NS-RoiProcessor.ijm
 * Purpose: To process a .roi file into usable results.
 */

shouldShowDebuggingDialog = false;

arguments = getArgument();
if(arguments == ""){
	tempChoices = newArray("Select a New File", "Use Default File");
	Dialog.create("Choose File Selection");
	Dialog.addChoice("Select a File?", tempChoices, tempChoices[1]);
	Dialog.show();
	tempChoice = Dialog.getChoice();
	if(tempChoice == tempChoices[1]){
		roiFilePath = "C:/Users/nicholas.sixbury/Desktop/Programs/ImageJ Macro Driver/" +
		"ImageJDriver/ImageJMacroD/bin/Debug/netcoreapp3.1/roi.zip";
		imgPath = "C:\\Users\\nicholas.sixbury\\Desktop\\Samples\\" +
		"2020 Oct - K Sullivan durum scan duplicates\\FGIS22-11D\\" +
		"FGIS22-11-1-1-D.tif";
		outputPath = "C:/Users/nicholas.sixbury/Desktop/Samples/results.txt";
	}//end if user selected default file
	else{
		// where we'll put the roi file
		roiFilePath = "C:/Users/nicholas.sixbury/Desktop/Programs/ImageJ Macro Driver/" +
		"ImageJDriver/ImageJMacroD/bin/Debug/netcoreapp3.1/roi.zip";
		// where we'll output all of our results
		outputPath = "C:/Users/nicholas.sixbury/Desktop/Samples/results.txt";
		// where we look for the image to open
		imgPath = File.openDialog("Select a non-flipped image file.");
	}//end else we want to let the user select something
}//end if we have no arguments
else{
	parts = split(arguments, "*");
	roiFilePath = parts[0];
	imgPath = parts[1];
	outputPath = parts[2];
}//end else we have no arguements

// threshold for detecting the entire kernel
lowTH = 60;
// threshold for detecting the chalky region
hiTH = 185;
// size limit for analyzing whole kernel in mm^2
minSz1 = 4;
// size limit for analyzing as chalky area
minSz2 = 1;
maxSz2 = 30;// amusingly, setting this to 15 is actually too small
// set line counter, which is a global variable
currentLine = 0;
before = 0;
after = 0;

// get all the roi
roiManager("open", roiFilePath);

// get all the results
open(imgPath);
run("Flip Horizontally");
run("8-bit");
run("Set Scale...", "distance=11.5 known=1 unit=mm global");
run("Set Measurements...","area centroid perimeter fit shape redirect=None decimal=2");
// loop over all the rois because of how analyze particles ignores roi
numROIs = roiManager("count");
baseImgId = getImageID();
// get the kernel results
for(i = 0; i < numROIs; i++){
	selectImage(baseImgId);
	roiManager("select", i);
	run("Duplicate...", "[TempImageWindow]");
	setThreshold(lowTH, 255);
	run("Analyze Particles...",
	"size=minSz1-30 circularity=0.1-1.00" + 
	" show=[Overlay Masks] display");
	close();
}//end looping over each roi for kernels
// close the temp windows
close("TempImageWindow");

// do the chalk results
if(is("Batch Mode")){
	print("Separator");
}//end if in batch mode
else{
	String.copyResults;
	allResults = String.paste();
	IJ.renameResults("kernels");
}//end else not in batch mode
run("Subtract Background...", "rolling=5 create");
for(i = 0; i < numROIs; i++){
	selectImage(baseImgId);
	roiManager("select", i);
	run("Duplicate...", "[TempImageWindow]");
	setThreshold(hiTH, 255);
	// save current number of chalk rows before particle analysis
	priorIndex = nResults - 1;
	// get the results
	run("Analyze Particles...",
		"size=minSz2-maxSz2 circularity=0.1-1.00" + 
		" show=[Overlay Masks] display");
	// save current number of chalk rows after particle analysis
	afterIndex = nResults - 1;
	seedNum = nResults+1;
	// record index in the results table
	if(priorIndex == afterIndex){
		if(priorIndex == -1 && afterIndex == -1){
			setResult("Seed Index", 0, i+1);
		}//end if this is the first item
		else{
			//setResult("Seed Index", nResults, i+1);
		}//end else we're just doing a normal item
	}//end if no rows were added
	else{
		for(j = priorIndex+1; j <= afterIndex; j++){
			setResult("Seed Index", j, i+1);
		}//end looping over indexes to add on results
	}//end else 1 or more rows were added
	updateResults();
	if(shouldShowDebuggingDialog){
		showMessageWithCancel("seedNum=" + seedNum +
			"\npriorIndex=" + priorIndex +
			"\nafterIndex="+afterIndex);
	}//end if we want to show debugging dialog
	close();
}//end looping over each roi for chalk
// close the temp windows
close("TempImageWindow");

if(is("Batch Mode")){
	
}//end if in batch mode
else{
	String.copyResults;
	allResults += String.paste();
	IJ.renameResults("chalks");
	File.saveString(allResults, outputPath);
}//end else not in batch mode