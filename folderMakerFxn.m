function [] = folderMakerFxn(folderPath)
%folderMakerFxn creates subfolder for each tif file and generates the tif files for spot identification
%   Takes in a folder containing the tif files obtained from the microscope
%   and creates a subfolder for each image containing the tif file, a
%   OriginalStack.mat file, and a First3Frames.tif file that can be
%   processed in Fiji to generate a Track Statistics.csv file for obtaining
%   locations for all spots.
    
    % List all contents of the provided directory with a .tif extension
    tifFiles = dir(fullfile(folderPath, '*.tif'));
    
    % Extract file names
    tifFileNames = string({tifFiles.name});
    
    % Create a subfolder for each .tif file without the extension
    for i = 1:numel(tifFileNames)
        % Remove the ".tif" extension
        folderName = strrep(tifFileNames(i), '.tif', '');
        fullPathCurrentTif = fullfile(folderPath, tifFileNames(i));
    
        % Create the subfolder path
        subfolderPath = fullfile(folderPath, folderName);
    
        % Check if the subfolder already exists, if not, create it
        if ~isfolder(subfolderPath)
            mkdir(subfolderPath);
            disp(['Subfolder created for ', tifFileNames(i)]);
            movefile(fullPathCurrentTif, subfolderPath)
            newFilePath = fullfile(subfolderPath, tifFileNames(i));
            [~, ~, OriginalStack] = firstFramesGenerator(newFilePath);
            save(fullfile(subfolderPath, 'OriginalStack.mat'), 'OriginalStack')
        end
    end
    disp('Folders generated. Proceeding to next step')


end