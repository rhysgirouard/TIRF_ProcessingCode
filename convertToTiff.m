function [convertedImagePath] = convertToTiff(sourceDir, destinationDir, imageName, ext)
%convertToTiff converts an image or image stack into the TIFF file format
%by using the BioFormats Importer in Fiji

sourceImagePath = fullfile(sourceDir, imageName);

% if source is already the correct type we can simply copy it into the new
% location
if strcmp(ext, '*.tif')
    convertedImagePath = fullfile(destinationDir, imageName);
    copyfile(sourceImagePath, convertedImagePath)
    if ~isfile(convertedImagePath)
        error(append('Failed to save ', convertedImagePath))
    end

    return
end


import ij.*;
import loci.plugins.BF.*;
import ij.io.FileSaver.*;

disp(['Opening image file: ', imageName]);


% Open the image using Bio-Formats
options = loci.plugins.in.ImporterOptions();
options.setConcatenate(true)
options.setOpenAllSeries(true)
options.setId(sourceImagePath);
imps = loci.plugins.BF.openImagePlus(options);  % This will return an array of ImagePlus objects
imp = imps(1); % There has to be a way to skip this step

% Check that the destination exists
if ~exist(destinationDir, 'dir')
    error(append('Folder ', destinationDir, ' does not exist!'))
end
% Saving the image
disp(['Saving to: ', destinationDir]);

newImageName = extractBefore(imageName, ext(2:end));
convertedImagePath = fullfile(destinationDir, [newImageName, '.tif']);
fs = ij.io.FileSaver(imp);
fs.saveAsTiff(convertedImagePath);

% Check if the save failed to create a file in the right place
if ~isfile(convertedImagePath)
    error(append('Failed to save ', convertedImagePath))
end

end