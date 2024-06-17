
Param (
        [Parameter(Mandatory=$true)][string]$code_folder,
        [Parameter(Mandatory=$true)][string]$fiji_path,
        [Parameter(Mandatory=$true)][string]$input_folder_var
)

#$code_folder = 'C:\Users\Rhys\GitHubFiles\TIRF_ProcessingCode'
#$fiji_path = 'C:\Users\Rhys\Downloads\fiji-win64\Fiji.app\ImageJ-win64'

#$input_folder_var = 'C:\Users\Rhys\exampleImage'
$results_folder="$input_folder_var`\Results"
mkdir "$results_folder"


# run a Fiji script to convert .nd2 files to .tif (headless mode does not work for BioFormatsImporter)
# Providing multiple inputs within a bash script is difficult so a single string is constructed and split on zzzzz within the python script

$conversionScript="$code_folder`\ConvertToTiff.py"
$formatted_input="$input_folder_var`zzzzz$results_folder`zzzzz.nd2"
$doubleSlash_input = $formatted_input -replace '\\', '\\\\'

$convertCommand = "$fiji_path --ij2 --console --run $conversionScript 'input=`"$doubleSlash_input`"'"
Invoke-Expression $convertCommand