function [nImage, NumberImages, correctedStack, background] = readInTimelapse(tifFilePath)
%readInTimelapse  Loads in the image as a 3D uint16 array for future use 

% Load image
InfoImage = imfinfo(tifFilePath);
mImage = InfoImage(1).Width;
nImage = InfoImage(1).Height;
NumberImages = length(InfoImage);
importedStack = zeros(nImage, mImage, NumberImages, 'uint16');
summedStack = zeros(nImage, mImage);

% copy image stack into a 3D array
for i = 1:NumberImages
   currentFrame = imread(tifFilePath, 'Index', i, 'Info', InfoImage);
   importedStack(:,:,i) = currentFrame;
   summedStack = summedStack + cast(currentFrame, 'double');
end

%TODO: if I can do this without imgaussfilt function then people dont have
%to add the Image processing toolbox to run the app. 
background = gaussianImageFilter(summedStack, 50)./NumberImages;
correctedStack = cast(importedStack, "double") - cast(background, "double");


end

function filteredImage = gaussianImageFilter(inputImage, sigma)
% recreates only necessary functionality from imgaussfilt() to apply a
% Gaussian filter to a 2D image. Adapted from the MathWorks Image
% Processing Toolbox

if isscalar(sigma)
    sigma = [sigma sigma];
end
hSize = 2*ceil(2*sigma) + 1;

% createGaussianKernel
filterRadius = (hSize-1)/2;
X = (-filterRadius(1):filterRadius(1))';
	arg = (X.*X)/(sigma(1)*sigma(1));
h = exp( -arg/2 );

% Suppress near-zero components	
h(h<eps*max(h(:))) = 0;

% Normalize
sumH = sum(h(:));
if sumH ~=0
    h = h./sumH;
end

hrowManual = h;
hcolManual = h;
hrowManual = reshape(hrowManual, 1, hSize(2));

% Calculate pad size
filter_center = floor((hSize + 1)/2);
padSizeManual = hSize - filter_center;

imageSize = size(inputImage);

%add padding
numDims = numel(padSizeManual);
% Form index vectors to subsasgn input array into output array.
% Also compute the size of the output array.
aIdx   = cell(1,numDims);
for k = 1:numDims
    M = imageSize(k);
    p = padSizeManual(k);
    onesVector = uint32(ones(1,p));
    aIdx{k}   = [onesVector 1:M M*onesVector];
end
bManual = inputImage(aIdx{:});

filteredImage = conv2(hcolManual, hrowManual, bManual,'valid');
end