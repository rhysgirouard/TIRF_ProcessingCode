#!/bin/bash

code_folder=$1
fiji_path=$2

if [ ! -f $fiji_path ]; then
    echo "The Fiji path provided does not lead to an executable. You may need to use Show package contents to find the correct file. Paste the correct path in the script and try again."
    exit
fi

input_folder_var=$3
results_folder=$input_folder_var'/Results'\


# run a Fiji script to convert .nd2 files to .tif (headless mode does not work for BioFormatsImporter)
# Providing multiple inputs within a bash script is difficult so a single string is constructed and split on zzzzz within the python script

conversionScript=$code_folder'/ConvertToTiff.py'
formatted_input=\"$input_folder_var'zzzzz'$results_folder'zzzzz'.nd2\"

$fiji_path --ij2 --console --run $conversionScript input=$formatted_input
