README

This code will process a folder of .nd2 images from the TIRF microscope and generate statistics and figures that track the intensity of light signal overtime as captured in the timelapse of the microscope. 

WARNING: Any spaces in provided folder paths can break the code so make sure to change any problematic paths
    Ex: Change /path/to/an example/file to path/to/an_example/file

INSTRUCTIONS:

For the first time only:
1. Ensure that all code components are in the same folder, that folder has been added to the MATLAB search path, and that path has been saved with savepath (simply opening matlab in the correct place is not enough as matlab will be called separately in the terminal)
	For example: >>addpath('/Users/rhysg/Documents/YalePGRA/MinimumRequiredFiles')
		     >>savepath
	-you can check what folders are on the path with >>path (it'll be at the top of the list)
	 you should check that it is still correct after restarting MATLAB as without the savepath command the path is not conserved between sessions

2. Determine the spot size and quality threshold for your data. You can do this by using trackMate on a representative acquisition. Lower quality thresholds are more likely to pick up background noise and auto fluorescent dust... 
    The defaults are a radius of 3 pixels and a quality of 50. You can determine what works best for you by previewing spot tracking in a manual Trackmate run.
    All data should be processed with the same settings though.

Before you run the code:
    The code processes all the images in the folder together and so will finish with all the images at the same time. 
    This means it can be better to process them in chunks so that you can start analyzing sooner.

The following errors are not issues and can be ignored:

    The operation couldn’t be completed. Unable to locate a Java Runtime that supports (null).
    Please visit http://www.java.com for information on installing Java.
    
    Warning: the font "Times" is not available, so "Lucida Bright" has been substituted, but may have unexpected appearance or behavor. Re-enable the "Times" font to remove this warning.
    
    Exception in thread "AWT-EventQueue-0" java.lang.NullPointerException...
    
    2024-03-21 12:22:13.045 MATLAB[12023:2449538] CoreText note: Client requested name ".SFNS-Regular", it will get TimesNewRomanPSMT rather than the intended font. All system UI font access should be through proper APIs such as CTFontCreateUIFontForLanguage() or +[NSFont systemFontOfSize:].
    2024-03-21 12:22:13.045 MATLAB[12023:2449538] CoreText note: Set a breakpoint on CTFontLogSystemFontNameRequest to debug. 

Every time you run the code:
1. Move the three channel image stacks to a separate folder. They confuse the code(these can be put back after figures have been generated)

2. Run matlabGUI and follow all prompt pop-ups. The first time it is run it will ask for some additional information

3. Wait for the program to finish in the background. Fiji will open images temporarily while it runs. You may need to switch to a different desktop to hide the Fiji pop-ups.

4. Group the image folders in results by sample conditions

5. Open an interactiveFig.fig

6. Use the number keys to ID a trace's number of steps. Pressing a number key will advance to the next trace. Using the left or right arrow keys will allow you to move through the traces without changing the assigned number of steps. The default number 0 indicates an uncounted trace. a,s,d keys will zoom in on the first 100,200,300 frames of the trace and the f key will return to the full view. You can also use the up and down arrow keys to zoom. 

7. If you use any other GUI components such as the zoom feature or the slider you must deselect that feature and click again on the graph to reactivate the keypress control.

8. Press the 'q' key to close and save the graph. If you do not press the q key entered data will not be saved to the .csv and will not be included in the counts later

9. You can reopen and resume or update any figure at any time.

10. Repeat steps 7-11 for all desired figures or until you have counted at least 1000 traces

11. Group any uncounted figures into a subfolder so that they don't contribute to summary statistics

12. Run tallySum('/path/to/sample') with the desired completed sample folder to create a .csv containing the totaled counts and approximated oligomer distribution from all .csv's in direct subfolders of the provided folder.
    Note that tallySum will count all figures in any subfolders of the given folder and thus will only provide useful information if folders have been grouped as instructed in steps 4 and 11
    Also note that tallySum is run automatically on the 'q' keyPress described in step 8 but may need to be rerun if you want to exclude folders as in step 11 or regroup as in step 4

