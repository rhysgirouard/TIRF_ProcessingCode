# README

This app will process a folder of .nd2 image stacks acquired on a TIRF microscope and generate statistics and figures for classifying step photobleaching. The app will identify individual spots and create figures that report fluorescence intensity over time and allow manual classification by keypress.

Requirements: Fiji and MATLAB

Developed on: Fiji 2.14.0/1.54f and MATLAB 2023b and the associated Image Processing toolbox

## INSTRUCTIONS:

### I. For the first time only:

1. Download the NNB_GUI.mlappinstall file from this GitHub

2. run the NNB_GUI.mlappinstall file

3. Add ImageJ-MATLAB to the your update site list in Fiji.(full instructions with pictures here: https://imagej.net/update-sites/following)
   1. Help>Update...
   2. After fiji is updated in the ImageJ updater window select 'Manage Update Sites"
   3. Check the box next to the ImageJ-MATLAB site (use the search bar to find it faster)
   4. Select add update site
   5. Select Apply Changes
   6. Restart Fiji

5. Add Image Processing Toolbox to MATLAB

6. Use the app menu at the top to open NNB_GUI

7. Use the Select File button to select the location of your Fiji installation (On Mac this is the Fiji app on Windows this should be the ImageJ exe)

8. Select the correct file type and channel. Leave other settings as is.

9. Follow below instructions (part II) to determine best spot size and quality.


### II. For each new imaging configuration

Since different microscope configurations will result in varied image specifications it is suggested that you determine the spot size and quality threshold for your data. You can do this by manually using trackMate on a representative acquisition. Lower quality thresholds are more likely to pick up background noise and auto fluorescent dust etc. The defaults are a spot radius of 3 pixels and a quality of 50. You can determine what works best for you by previewing spot tracking in a manual Trackmate run. All data should be processed with the same settings. The best way to test this is as follows

1. Place a representative image stack acquisition in its own folder
   
3. Open MATLAB
4. Use the app menu at the top to open NNB_GUI and follow instructions in section IV. to process your single stack folder
5. In Fiji, open the file titled First3Frames.tif created in the sub-subfolder of the Results folder 
6. In the menubar go to Plugins>Tracking>Trackmate
7. In the Z/T Swapped popup select 'Yes'
8. Click Next without changing calibration or crop settings
9. Select DoG detector 
10. Activate 'Pre-process with median filter' and 'Sub-pixel localization'
11. Try different object diameters and quality thresholds and use Preview to see what is circled
12. repeat until you get settings where all spots are circled and no background noise is selected. 
13. Note down the quality and diameter that worked best(NOTE: the code asks for RADIUS so divide diameter by two)
14. Run NNB_Settings and answer popups
15. Proceed with counting.	


### III. Before you run the code:

1. Move the three channel image stacks to a separate folder. They confuse the code(these can be put back after figures have been generated)
2. The code processes all the files in the folder together and so will finish with all the images at the same time. If desired separate your image stacks and process in chunks. 


### IV. Every time you run the code:

1. Open the NNB_GUI app from the app section of the MATLAB menu bar

2. Click Load Last Settings

3. Check that settings are correct.

4. Select the folder with the desired image stacks with "Select Folder"

5. Click "Process Images"

6. Answer any prompts 

7. Wait for the program to finish in the background. When figures are being saved at the very end MATLAB will briefly steal focus

8. Follow annotation instructions in Part V.

If the app is failing it may be easier to use/debug the script(NNB_ImageProcessingScript)
1. Open MATLAB

2. Run NNB_ImageProcessingScript and follow all prompt pop-ups. The first time it is run it will ask for some additional information. If this needs to be changed you can delete NNBprocessingSettings.mat before running the image processing script or run NNB_Settings.m separately

3. Wait for the program to finish in the background. When figures are being saved at the very end MATLAB will briefly steal focus.


### V. After you run the code (Annotate traces)

1. Group the image folders in results by sample conditions

2. Open an interactiveFig.fig

3. Use the number keys to ID a trace's number of steps. Pressing a number key will classify that trace and then advance to the next trace. Using the left or right arrow keys will allow you to move through the traces without changing the assigned number of steps. The number 0 indicates an uncounted/discarded trace. a, s, d keys will zoom in on the first 100, 200, 300 frames of the trace and the f key will return to the full view. You can also use the up and down arrow keys to increase or decrease the y range by 100. Increasing at the maximum will loop around to the minimum and vice versa.

4. If you use any other figure GUI components such as the zoom feature or the slider you must deselect that feature and click again on the graph to reactivate the keypress controls.

5. Press the 'q' key to close and save the graph. If you do not press the q key entered data will not be saved to the .csv and will not be included in the counts later (although the information is not lost you just must reopen the figure and press 'q'.)

6. You can reopen and resume or update any figure at any time.

7. Repeat steps 2-5 for all desired figures or until you have identified steps in at least 1000 traces

8. (Optional)Run tallySum('/path/to/sample') with the desired completed sample folder to create a .csv containing the totaled counts and approximated oligomer distribution from all .csv's in direct subfolders of the provided folder.
    Note that tallySum will count all figures in any subfolders of the given folder and thus will only provide useful information if folders have been grouped as instructed in step 1
    Also note that tallySum is run automatically on the 'q' keyPress described in step 8 but may need to be rerun if you want to update stats after you exclude folders as in step 11 or regroup as in step 4

9. View results saved in the sumOfCounts.xlsx file

### TroubleShooting:
Common Errors:
1. [WARNING] Could not set Look & Feel ''
	You can safely ignore this warning

2. java.lang.OutOfMemoryError or similar out of memory error in the ImageJ portions of processing
	This is likely a result of java being allotted only a small portion of RAM by default(~10% or your computer's total RAM) and needing ~800MB(this depends on the size of your image stacks) to store an image while processing it. This can be resolved by going to Preferences>General>Java Heap Memory and increasing the Java Heap Size. More Info here: https://imagej.net/scripting/matlab#memory-issue

3. Generally if there are other files especially image files in the folder being processed this can confuse the code. 

4. Did you add ImageJ-MATLAB to Fiji and the Image Processing toolbox to MATLAB?
