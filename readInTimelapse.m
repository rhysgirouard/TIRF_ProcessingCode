function [nImage, NumberImages, OriginalStack] = readInTimelapse(tifFilePath)
%readInTimelapse  Loads in the image as a 3D uint16 array for future use 

% Load image
InfoImage=imfinfo(tifFilePath);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
OriginalStack=zeros(nImage,mImage,NumberImages,'uint16');

% copy image stack into a 3D array
for i=1:NumberImages
   OriginalStack(:,:,i)=imread(tifFilePath,'Index',i,'Info',InfoImage);
end

end