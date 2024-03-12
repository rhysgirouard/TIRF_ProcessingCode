#!/bin/bash

# NOTE: you must move the 3 channel images to a separate folder or the code will try to process them and get very confused

#FIRST TIME SET UP: paste correct folder path for all code below and add and save that path to the MATLAB search path
code_folder='/Users/rhysg/Documents/YalePGRA/TIRF_ProcessingCode'
code_folder_single_quotes="'"$code_folder"'"

#CHECK THAT THE FOLLOWING PATHS ARE CORRECT FOR YOU (You may have to change this the first time)
matlab_path='/Applications/MATLAB_R2023b.app/bin/matlab'
fiji_path='/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx'

#YOU SHOULD NOT HAVE TO EDIT ANYTHING BELOW THIS

#This asks for the folder path from the user when the script is run.
echo Type/Paste the input folder path and press enter
read input_folder_var

answer='N'
while [[ $answer != 'Y' ]];
do
echo Does input_folder_var contain only the .nd2 files you wish to process'('i.e. no 3 channel images, partial timelapses, or other files/folders')'? '('Y/N')'
read answer
done

# makes a folder for all outputs (zz_ is used to place the folder last alphabetically so that the script can process all but the last entry)
results_folder=$input_folder_var'/zz_Results'
mkdir $results_folder

#adds quotes for correct interpretation by further code
results_folder_single_quotes="'"$results_folder"'"
results_folder_double_quotes="\"$results_folder\""


# run a Fiji macro to convert .nd2 files to .tif (headless mode does not work for BioFormatsImporter)
conversionMacro=$code_folder'/ConvertToTifMacroForBash.ijm'
$fiji_path -macro $conversionMacro $input_folder_var

# run Matlab folderMaker on folder to generate first3frames and subfolders for each time-lapse
$matlab_path -nodisplay -r "folderMakerFxn($results_folder_single_quotes) ; exit;"


# Run a fiji python script to create trackstatistics for each firstFrames using Trackmate
# This can't run headlessly because the exportToCSV method relies on a class forbidden by headless mode(Table)
trackMateScript=$code_folder'/TrackMateForBash.py'
$fiji_path --ij2 --console --run $trackMateScript folder_path=$results_folder_double_quotes

# call a Matlab function for generating figures
$matlab_path -nodisplay -r "figureSaverOriginalFig($results_folder_single_quotes) ; exit;"

# The following removes the ugly 'zz_' from the results folder name	
mv $results_folder $input_folder_var'/Results'