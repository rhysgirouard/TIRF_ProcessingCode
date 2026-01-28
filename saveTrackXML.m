function saveTrackXML(executablePath, appPath, imagePath, folderPath, spotRadius, qualityThreshold, channel)


scriptPath = fullfile(appPath, "saveTrackmateXML.py");

image = "'" + imagePath + "'";
folder = "'" + folderPath + "'";
radius = num2str(spotRadius);
quality = num2str(qualityThreshold);

args = sprintf("imagePath=%s,folderPath=%s,radius=%s,quality=%s,channel=%s",...
    image, folder, radius, quality, channel);
if ismac()
    cmd = sprintf('"%s" --headless --run "%s" "%s"', executablePath, scriptPath, args);
elseif ispc()
    cmd = sprintf('"%s" --headless --console --run "%s" "%s"', executablePath, scriptPath, args);
else
    warning("WARNING! unsupported OS")
    cmd = sprintf('"%s" --headless --run "%s" "%s"', executablePath, scriptPath, args);
end
try
    status = system(cmd);
catch ME
    if ismac() 
        cmd = sprintf('"%s" --headless --script "%s" "%s"', executablePath, scriptPath, args);
    elseif ispc()
        cmd = sprintf('"%s" --headless --console --script "%s" "%s"', executablePath, scriptPath, args);
    else
        cmd = sprintf('"%s" --headless --script "%s" "%s"', executablePath, scriptPath, args);
    end
    status = system(cmd);
end
if status ~= 0
    error('TrackMate failed to run.');
end

% TODO: check for these characters in provided paths
badchars = ["'", "`", """", "/", ":", "\"];
end