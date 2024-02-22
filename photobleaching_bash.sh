#!/bin/bash

# NOTE: you must move the 3 channel images to a separate folder or the code will try to process them and get very confused

#FIRST TIME SET UP: paste correct folder path for all code below and add and save that path to the MATLAB search path
code_folder='/Users/rhysg/Documents/YalePGRA/MinimumRequiredFiles'
code_folder_single_quotes="'"$code_folder"'"

#CHECK THAT THE FOLLOWING PATHS ARE CORRECT FOR YOU
matlab_path='/Applications/MATLAB_R2023b.app/bin/matlab'
fiji_path='/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx'

#EACH TIME YOU PROCESS A NEW FOLDER
# Paste the path for the folder of .nd2 files here. Do not use spaces in folder name or the code will break
input_folder_var='/Volumes/Rhys-YALE_PGRA_MB_DATA/10-18-23-NRasWT-Reprocessed'

#YOU SHOULD NOT HAVE TO EDIT ANYTHING BELOW THIS

# makes a folder for all outputs
results_folder=$input_folder_var'/zz_Results'
mkdir $results_folder

#adds quotes for correct interpretation by later code
results_folder_single_quotes="'"$results_folder"'"
results_folder_double_quotes="\"$results_folder\""


# run fiji macro to convert .nd2 files to .tif (headless mode does not work for BioFormatsImporter)
conversionMacro=$code_folder'/ConvertToTifMacroForBash.ijm'
$fiji_path -macro $conversionMacro $input_folder_var

# run matlab folderMaker on folder to generate first3frames and subfolders for each timelapse
$matlab_path -nodisplay -r "folderMakerFxn($results_folder_single_quotes) ; exit;"


# Run fiji python to create trackstatistics for each firstFrames using Trackmate
# Can't run headlessly because the exportToCSV method relies on a class forbidden by headless mode(Table)
trackMateScript=$code_folder'/TrackMateForBash.py'
$fiji_path --ij2 --console --run $trackMateScript folder_path=$results_folder_double_quotes

# run matlab script for generating figures
$matlab_path -nodisplay -r "figureSaverOriginalFig($results_folder_single_quotes) ; exit;"

# The following removes the ugly 'zz_' from the results folder name	
mv $results_folder $input_folder_var'/Results'