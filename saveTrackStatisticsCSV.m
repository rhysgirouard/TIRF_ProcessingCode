function saveTrackStatisticsCSV(imagePath, folderPath, spotRadius, qualityThreshold)
% runs Trackmate on the provided image and saves track statistics in the
% folderPath. Requires ImageJ to be running and some javaaddapths



% Import necessary Java classes
import java.lang.Integer

import ij.*;
import ij.WindowManager;
import java.io.File;
import fiji.plugin.trackmate.Model;
import fiji.plugin.trackmate.Settings;
import fiji.plugin.trackmate.TrackMate;
import fiji.plugin.trackmate.SelectionModel;
import fiji.plugin.trackmate.Logger;
import fiji.plugin.trackmate.detection.DogDetectorFactory;
import fiji.plugin.trackmate.tracking.kdtree.NearestNeighborTrackerFactory;
import fiji.plugin.trackmate.visualization.table.TrackTableView;
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettings;
% Open the image
imp = IJ.openImage(imagePath);

% Swap Z and T dimensions
dims = imp.getDimensions();
imp.setDimensions(dims(3), dims(5), dims(4));

% Create model and settings
model = Model();
model.setLogger( Logger.IJ_LOGGER )
settings = Settings(imp);

% Configure detector
settings.detectorFactory = DogDetectorFactory();
map = java.util.HashMap();
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', spotRadius);
map.put('TARGET_CHANNEL', Integer.valueOf(1)); % Needs to be an integer, otherwise TrackMate complaints.
map.put('THRESHOLD', qualityThreshold);
map.put('DO_MEDIAN_FILTERING', true);
settings.detectorSettings = map;
% Configure tracker
settings.trackerFactory = NearestNeighborTrackerFactory();
settings.trackerSettings = settings.trackerFactory.getDefaultSettings();
settings.trackerSettings.put('LINKING_MAX_DISTANCE', 15.0);

% Add all analyzers
settings.addAllAnalyzers();

% Instantiate TrackMate
trackmate = TrackMate(model, settings);

% Check and process
if ~trackmate.checkInput()
    disp(trackmate.getErrorMessage());
    return;
end

if ~trackmate.process()
    disp(trackmate.getErrorMessage());
    return;
end

% Save CSVs
sm = SelectionModel(model);
ds = DisplaySettings();
fullPath = fullfile(folderPath, 'Track statistics.csv');
tracksFile = java.io.File(fullPath);
trackTableView = TrackTableView(model, sm, ds, imagePath);
trackTableView.getTrackTable().exportToCsv(tracksFile);

% Close the image
imp.close();
end


