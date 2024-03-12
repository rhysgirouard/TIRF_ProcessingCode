README

This code will process a folder of .nd2 images from the TIRF microscope and generate statistics and figures that track the intensity of light signal overtime as captured by the timelapse of the microscope. 

WARNING: the code is not very robust to file manipulation. Files should not be removed from the results folder after generation or the figures might break

INSTRUCTIONS:

For the first time only:
1. Ensure that all code components are in the same folder and that folder has been added to the MATLAB search path and that path has been saved with savepath
	For example: >>addpath('/Users/rhysg/Documents/YalePGRA/MinimumRequiredFiles')
		     >>savepath
	-you can check what folders are on the path with >>path
	 you should check that it is still correct after restarting MATLAB as without the savepath 	 command the path is not conserved between sessions

2. Open the photobleaching_bash.sh file in a text editor and set the code_folder variable to the correct path for you

3. Check that the matlab_path and fiji_path variables are pointing to the correct locations on your computer( note that this is not just the application path itself but specific content; it should be very similar for most users though)

4.Save your changes to the .sh file

Every time you run the code:
1. move the three channel image stacks to a separate folder. They confuse the code(these can be put back after figures have been generated)

2. open a terminal window and run /bin/bash /path/to/file/photobleaching_bash.sh replacing /path/to/file with the correct path

3. When prompted by the terminal paste the path to the folder of .nd2 images and press enter

4. Check that the provided folder does not contain any other files then type 'Y' and press enter.

4. After the terminal finishes the Results folder should be renamed to Results instead of zz_Results. If it is still zz_Results there has been an error

6. Group the image folders in results by sample conditions

7. Open an interactiveFig.fig

8. Use the number keys to ID a trace's number of steps. Pressing a number key will advance to the next trace. Using the left or right arrow keys will allow you to move through the traces without changing the assigned number of steps. The default number 0 indicates an uncounted trace. a,s,d keys will zoom in on the first 100,200,300 frames of the trace and the f key will return to the full view. 

9. If you use any other GUI components such as the zoom feature or the slider you must deselect that feature and click again on the graph to reactivate the keypress control.

10. Press the q key to close and save the graph. If you do not press the q key entered data will not be saved to the .csv and will not be included in the counts later

11. You can reopen and resume or update any figure at any time.

12. Repeat steps 7-11 for all desired figures

13.Group any uncounted figures into a subfolder

13. Run tallySum('/path/to/sample') with the desired completed sample folder to create a .csv containing the totaled counts and approximated oligomer distribution from all .csv's in direct subfolders of the provided folder.

