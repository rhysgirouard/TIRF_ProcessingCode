function [nImage, NumberImages, OriginalStack] = firstFramesGenerator(pathInput)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

FileTif=pathInput;

OutputFileName1 = 'First3frames.tif';
% Do not change
[path,name,ext] = fileparts(FileTif);
OutputFile1 = fullfile(path,OutputFileName1);
NoProjection = 3;

% Load image
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
OriginalStack=zeros(nImage,mImage,NumberImages,'uint16');
for i=1:NumberImages
   OriginalStack(:,:,i)=imread(FileTif,'Index',i,'Info',InfoImage);
end
% Create and write Z-Projection image

ZProjection=OriginalStack(:,:,1);
for i=2:NoProjection
    ZProjection=ZProjection+OriginalStack(:,:,i);
end

for i=1:5
    imwrite(ZProjection,OutputFile1,'WriteMode','append','Compression','none');
end
end