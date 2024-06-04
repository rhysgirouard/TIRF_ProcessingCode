#!/bin/bash

code_folder=$1
fiji_path=$2
input_folder_var=$3
results_folder=$input_folder_var'/Results'
results_folder_double_quotes="\"$results_folder\""

# Run a fiji python script to create trackstatistics for each firstFrames using Trackmate
# This can't run headlessly because the exportToCSV method relies on a class forbidden by headless mode(Table)
trackMateScript=$code_folder'/TrackMateForBash.py'
$fiji_path --ij2 --console --run $trackMateScript folder_path=$results_folder_double_quotes
