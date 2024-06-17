function [] = convertToTiff(sourceDir, destinationDir, imageName)
disp(['Processing: ', imageName]);

% Opening the image
disp(['Open image file: ', imageName]);
imagePath = fullfile(sourceDir, imageName);

% Using MIJ to open the image with Bio-Formats
options = ['open=[', imagePath, ']'];
MIJ.run('Bio-Formats Windowless Importer', options);
imp = ij.IJ.getImage();

% Put your processing commands here!

% Saving the image
if ~exist(destinationDir, 'dir')
    error(append('Folder ', destinationDir, ' does not exist!'))
end
disp(['Saving to: ', destinationDir]);
savepath = fullfile(destinationDir, [imageName, '.tif']);
ij.IJ.saveAsTiff(imp, savepath);
imp.close();

if ~isfile(savepath)
    error(append('Failed to save ', savepath))
end


end