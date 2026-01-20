function saveTrackXML(fijiPath, appPath, imagePath, folderPath, spotRadius, qualityThreshold, channel)

if ~isfile(fijiPath)
    error("Could not locate ImageJ path for scripting")
end

scriptPath = fullfile(appPath, "saveTrackmateXML.py");


image = "'" + imagePath + "'";
folder = "'" + folderPath + "'";
radius = num2str(spotRadius);
quality = num2str(qualityThreshold);
channel = num2str(channel);

args = sprintf("imagePath=%s,folderPath=%s,radius=%s,quality=%s,channel=%s",...
    image, folder, radius, quality, channel);
if ismac()
    cmd = sprintf('"%s" --headless --run "%s" "%s"', executablePath, scriptPath, args);
elseif ispc()
    cmd = sprintf('%s --headless --console --run "%s" "%s"', executablePath, scriptPath, args);
else
    warning("WARNING! unsupported OS")
    cmd = sprintf('"%s" --headless --run "%s" "%s"', executablePath, scriptPath, args);
end
status = system(cmd);

if status ~= 0
    error('TrackMate failed to run.');
end

end