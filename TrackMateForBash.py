import sys

from ij import IJ
from ij import WindowManager

import java.io.File;
import os

from java.lang import System;


from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.detection import DogDetectorFactory
from fiji.plugin.trackmate.tracking.kdtree import NearestNeighborTrackerFactory

# from fiji.plugin.trackmate.gui.displaysettings import DisplaySettingsIO
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettings

import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter


from fiji.plugin.trackmate.visualization.table import TrackTableView
from fiji.plugin.trackmate.visualization.table import AllSpotsTableView

def saveTrackStatisticsCSV(imagePath, folderPath):

	# We have to do the following to avoid errors with UTF8 chars generated in 
	# TrackMate that will mess with our Fiji Jython.
	reload(sys)
	sys.setdefaultencoding('utf-8')

	# Get currently selected image
	# imp = WindowManager.getCurrentImage()
	imp = IJ.openImage(imagePath)
	imp.show()

	#Swap Z and T 
	dims = imp.getDimensions();
	imp.setDimensions( dims[ 2 ], dims[ 4 ], dims[ 3 ] );


	#----------------------------
	# Create the model object now
	#----------------------------

	# Some of the parameters we configure below need to have
	# a reference to the model at creation. So we create an
	# empty model now.

	model = Model()

	# Send all messages to ImageJ log window.
	model.setLogger(Logger.IJ_LOGGER)



	#------------------------
	# Prepare settings object
	#------------------------

	settings = Settings(imp)

	# Configure detector - We use the Strings for the keys
	settings.detectorFactory = DogDetectorFactory()
	settings.detectorSettings = {
    	'DO_SUBPIXEL_LOCALIZATION' : True,
    	'RADIUS' : 3.,
    	'TARGET_CHANNEL' : 1,
    	'THRESHOLD' : 50.,
    	'DO_MEDIAN_FILTERING' : True,
	}  



	# Configure tracker - We want to allow merges and fusions
	settings.trackerFactory = NearestNeighborTrackerFactory()
	settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
	settings.trackerSettings['LINKING_MAX_DISTANCE'] = 15.;

	# Add ALL the feature analyzers known to TrackMate. They will 
	# yield numerical features for the results, such as speed, mean intensity etc.
	settings.addAllAnalyzers()


	#-------------------
	# Instantiate plugin
	#-------------------

	trackmate = TrackMate(model, settings)

	#--------
	# Process
	#--------

	ok = trackmate.checkInput()
	if not ok:
		sys.exit(str(trackmate.getErrorMessage()))

	ok = trackmate.process()
	if not ok:
		sys.exit(str(trackmate.getErrorMessage()))


	#----------------
	# Save CSVs
	#----------------

	# Create default SelectionModel and DisplaySettings
	sm = SelectionModel(model)
	ds = DisplaySettings()

	fullPath = folderPath + '/Track statistics.csv'
	tracksFile = java.io.File(fullPath)
	trackTableView = TrackTableView(model, sm, ds)

	trackTableView.getTrackTable().exportToCsv(tracksFile)

def process_subfolders(folder_path):
    """
    Process each subfolder in the given folder, and run the specified function on each .tif file.

    Parameters:
    - folder_path (str): The path of the main folder.
    - processing_function (callable): The function to run on each .tif file.
    """
    # Iterate over each subfolder in the main folder
    for subfolder in os.listdir(folder_path):
        subfolder_path = os.path.join(folder_path, subfolder)

        # Check if the item is a subfolder
        if os.path.isdir(subfolder_path):
            print("Processing subfolder: " + subfolder)

            # Iterate through each file in the subfolder
            for file_name in os.listdir(subfolder_path):
                file_path = os.path.join(subfolder_path, file_name)

                # Check if the file is a .tif file
                if file_name.lower().endswith('3frames.tif'):
                    print("Processing file: " + file_name)
                    # Run the specified processing function on the file
                    saveTrackStatisticsCSV(file_path, subfolder_path)
    
    print("Processing complete.")
    
#@ String folder_path

process_subfolders(folder_path)

System.exit(0);
