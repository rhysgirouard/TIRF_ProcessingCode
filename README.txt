README

This code will precess a folder of .nd2 images from the TIRF microscope and generate statistics and figures that track the intensity of light signal overtime as captured by the timelapse of the microscope. 

WARNING: the code is not very robust to file manipulation. Files should not be removed from the results folder after generation or the figures might break

INSTRUCTIONS:

For the first time only:
1. Ensure that all components are in the same folder and that folder has been added to the MATLAB search path and that path has been saved with savepath
	For example: >>addpath('/Users/rhysg/Documents/YalePGRA/MinimumRequiredFiles')
		     >>savepath
	-you can check what folders are on the path with >>path
	 you should check that it is still correct after restarting MATLAB as without the save path 	 command the path is not saved between sessions

2. Open the photobleaching_bash.sh file in a text editor and set the code_folder variable to the correct path for you

3.Save your changes to the .sh file

Every time you run the code:
1. move the three channel image stacks to a separate folder they confuse the code(these can be put back after figures have been generated

2. Open the photobleaching_bash.sh file in a text editor and set the input_folder_var to the folder file path that contains the .nd2 images

3.  save your changes to the .sh file

4. open a terminal window and run /bin/bash /path/to/file/photobleaching_bash.sh replacing /path/to/file with the correct path

5. After the terminal finishes the Results folder should be renamed to Results instead of zz_Results. If it is still zz_Results there has been an error

6. Group the image folders in results by sample conditions

7. open a interactiveFig

8. use the number keys to ID a graph's number of steps. Pressing a number key will advance to the next graph. Using the left or right arrow keys will allow you to move through the graphs without changing the assigned number of steps.

9. If you use any other GUI components such as the zoom feature you must deselect that feature and click again on the graph to reactivate the button control.

10. Press the q key to close and save the graph. If you do not press the q key entered data will not be saved

11. You can reopen and resume or update any graph at any time.

12. Repeat steps 7-11 for all desired graphs

13. Run tallySum('/path/to/sample') with the desired competed sample folder to create a csv containing the totaled counts of each digit from all subfolders of the provided folder.

