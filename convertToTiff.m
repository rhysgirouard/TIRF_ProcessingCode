function [] = convertToTiff(sourceDir, destinationDir, imageName)
import ij.*;
import loci.plugins.BF.*;
import ij.io.FileSaver.*;

disp(['Opening image file: ', imageName]);
imagePath = fullfile(sourceDir, imageName);

% Open the image using Bio-Formats
options = loci.plugins.in.ImporterOptions();
options.setConcatenate(true)
options.setOpenAllSeries(true)
options.setId(imagePath);
imps = loci.plugins.BF.openImagePlus(options);  % This will return an array of ImagePlus objects
imp = imps(1); % There has to be a way to skip this step

% Check that the destination exists
if ~exist(destinationDir, 'dir')
    error(append('Folder ', destinationDir, ' does not exist!'))
end
% Saving the image
disp(['Saving to: ', destinationDir]);

newImageName = extractBefore(imageName, '.nd2');
savepath = fullfile(destinationDir, [newImageName, '.tif']);
fs = ij.io.FileSaver(imp);
fs.saveAsTiff(savepath);

% Check if the save failed to create a file in the right place
if ~isfile(savepath)
    error(append('Failed to save ', savepath))
end

end