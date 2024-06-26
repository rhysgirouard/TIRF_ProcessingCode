README

This code will process a folder of .nd2 images from the TIRF microscope and generate statistics and figures that track the intensity of light signal overtime as captured in the timelapse of the microscope. 

Requirements:
Fiji and MATLAB

INSTRUCTIONS:

For the first time only:

1. Add ImageJ-MATLAB to the your update site list in Fiji.(full instructions with pictures here: https://imagej.net/update-sites/following) 
	a. Help>Update...
	b. after fiji is updated in the ImageJ updater window select 'Manage Update Sites"
	c. check the box next to the ImageJ-MATLAB site
	d. Select add update site
	d. Select Apply Changes
	e. restart Fiji

2. Determine the spot size and quality threshold for your data. You can do this by using trackMate on a representative acquisition. Lower quality thresholds are more likely to pick up background noise and auto fluorescent dust etc. The defaults are a radius of 3 pixels and a quality of 50. You can determine what works best for you by previewing spot tracking in a manual Trackmate run. All data should be processed with the same settings. The best way to test this is as follows:
	a. Place a representative timelapse acquisition in its own folder
	b. Open MATLAB
	c. Run the first section of NNB_ImageProcessingScript.m. Answer the popups. Use the default spot size and quality. Provide the above folder as the input folder
	d. Run the second and third sections of NNB_ImageProcessingScript.m
	e. In Fiji, open the file titled First3Frames.tif created in the sub-subfolder of the provided folder 
	f. In the menubar go to Plugins>Tracking>Trackmate
	g. In the Z/T Swapped popup select 'Yes'
	h. Click Next without changing calibration or crop settings
	i. Select DoG detector 
	j. Activate 'Pre-process with median filter' and 'Sub-pixel localization'
	k. Try different object diameters and quality thresholds and use Preview to see what is circled
	l. repeat until you get settings where all spots are circled and no background noise is selected. 
	m. Note down the quality and diameter that worked best(NOTE: the code asks for RADIUS so divide diameter by two)
	n. Run NNB_Settings and answer popups
	o. Proceed with counting.	

Before you run the code:
1. Move the three channel image stacks to a separate folder. They confuse the code(these can be put back after figures have been generated)
2. The code processes all the images in the folder together and so will finish with all the images at the same time. This means it can be better to process them in chunks so that you can start analyzing sooner.

Every time you run the code:
1. Open MATLAB

2. Run NNB_ImageProcessingScript and follow all prompt pop-ups. The first time it is run it will ask for some additional information. If this needs to be changed you can delete NNBprocessingSettings.mat or run NNB_Settings

3. Wait for the program to finish in the background. Fiji will open images temporarily while it runs. You may need to switch to a different desktop to hide the Fiji pop-ups.

4. Group the image folders in results by sample conditions

5. Open an interactiveFig.fig

6. Use the number keys to ID a trace's number of steps. Pressing a number key will advance to the next trace. Using the left or right arrow keys will allow you to move through the traces without changing the assigned number of steps. The default number 0 indicates an uncounted/discarded trace. a,s,d keys will zoom in on the first 100,200,300 frames of the trace and the f key will return to the full view. You can also use the up and down arrow keys to increase or decrease the y range by 100. Increasing at the maximum will loop around to the minimum.

7. If you use any other GUI components such as the zoom feature or the slider you must deselect that feature and click again on the graph to reactivate the keypress control.

8. Press the 'q' key to close and save the graph. If you do not press the q key entered data will not be saved to the .csv and will not be included in the counts later

9. You can reopen and resume or update any figure at any time.

10. Repeat steps 7-11 for all desired figures or until you have counted at least 1000 traces

11. Group any uncounted figures into a subfolder so that they don't contribute to summary statistics

12. Run tallySum('/path/to/sample') with the desired completed sample folder to create a .csv containing the totaled counts and approximated oligomer distribution from all .csv's in direct subfolders of the provided folder.
    Note that tallySum will count all figures in any subfolders of the given folder and thus will only provide useful information if folders have been grouped as instructed in steps 4 and 11
    Also note that tallySum is run automatically on the 'q' keyPress described in step 8 but may need to be rerun if you want to exclude folders as in step 11 or regroup as in step 4

TroubleShooting:
Common Errors:
1. java.lang.OutOfMemoryError or similar out of memory error in the ImageJ portions of processing
	This is a result of java being allotted only a small portion of RAM by default(~10% or your computer's total RAM) and needing ~800MB to store an image while processing it. This can be resolved by going to Preferences>General>Java Heap Memory and increasing the Java Heap Size.
