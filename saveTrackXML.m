function saveTrackXML(fijiPath, appPath, imagePath, folderPath, spotRadius, qualityThreshold, channel)


if ismac()
    executablePath = fullfile(fijiPath, "Contents/MacOS/ImageJ-macosx");
    if ~isfile(executablePath)
        error("Could not locate ImageJ path for scripting")
    end
end

scriptPath = fullfile(appPath, "saveTrackmateXML.py");

image = "'" + imagePath + "'";
folder = "'" + folderPath + "'";
radius = num2str(spotRadius);
quality = num2str(qualityThreshold);
channel = num2str(channel);

args = sprintf("imagePath=%s,folderPath=%s,radius=%s,quality=%s,channel=%s",...
    image, folder, radius, quality, channel);
cmd = sprintf('"%s" --headless --run "%s" "%s"', executablePath, scriptPath, args);

status = system(cmd);

if status ~= 0
    error('TrackMate failed to run.');
end

end