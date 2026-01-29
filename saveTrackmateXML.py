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

from fiji.plugin.trackmate.io import TmXmlWriter

#@ String imagePath
#@ String folderPath
#@ Float radius
#@ Float quality
#@ Float channel

channel = int(channel)


# We have to do the following to avoid errors with UTF8 chars generated in 
	# TrackMate that will mess with our Fiji Jython.
reload(sys)
sys.setdefaultencoding('utf-8')

imp = IJ.openImage(imagePath)

#Check whether you need to swap Z and T 
dims = imp.getDimensions();
if dims[ 3 ] > dims[ 4 ]:
	imp.setDimensions( dims[ 2 ], dims[ 4 ], dims[ 3 ] );

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
    'RADIUS' : radius,
    'TARGET_CHANNEL' : channel,
    'THRESHOLD' : quality,
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
# Save XML
#----------------

# Create default SelectionModel
sm = SelectionModel(model)

target_xml_filename = os.path.join(folderPath, 'TrackmateData.xml')
target_xml_file = java.io.File( target_xml_filename )
writer = TmXmlWriter( target_xml_file, Logger.IJ_LOGGER )
 
# Append content. Only the model is mandatory.
writer.appendModel( model )
writer.appendSettings( settings )

# Actually write the file.
writer.writeToFile()
imp.close()
