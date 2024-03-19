function [] = figureSaverOriginalFig(tifFolderPath)
%FIGURESAVERFXN creates figures for each of the prepared folders 
%   goes through the subfolders in the given folder and calls
%   tracePlotterFxn to create figures containing the intensity over time
%   graphs for all spots identified in the respective timelapse

% List all contents of the supplied folder
contents = dir(tifFolderPath);

% Filter out only the subfolders
subfolderNames = {contents([contents.isdir] & ~ismember({contents.name}, {'.', '..'})).name};

% Convert to string array
subfolderNames = string(subfolderNames);

% Display the list of subfolder names
disp('Subfolders in the current directory:');
disp(subfolderNames);

% Loop through each subfolder and pass its file path to the external function
for i = 1:numel(subfolderNames)
    subfolderPath = fullfile(tifFolderPath, subfolderNames(i));
    subfolderPathChar = convertStringsToChars(subfolderPath);
    tracePlotterOirginalFig(subfolderPathChar);
    interactiveTraceGenerator(subfolderPathChar);                                                                                                               
end
end