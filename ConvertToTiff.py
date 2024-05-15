#@ String input

# See also Process_Folder.ijm for a version of this code
# in the ImageJ 1.x macro language.

import os
from ij import IJ, ImagePlus
from loci.plugins import BF
from java.lang import System;

def run():
  srcDir = srcFile
  dstDir = dstFile
  filenames = os.listdir(srcDir)
  filenames.sort()
  for filename in filenames:
  	# Check for file extension
    if not filename.endswith(ext):
    	continue
    process(srcDir, dstDir, filename)
 
def process(srcDir, dstDir, fileName):
  print "Processing:"
   
  # Opening the image
  print "Open image file", fileName
  imagePath = os.path.join(srcDir, fileName)
  openString = "open=" + imagePath;
  IJ.run("Bio-Formats Windowless Importer", openString);
  imp = IJ.getImage()
   
  # Put your processing commands here!
   
  # Saving the image
  
  if not os.path.exists(dstDir):
    os.makedirs(dstDir)
  print "Saving to", dstDir
  savepath = os.path.join(dstDir, fileName);
  savepath = os.path.splitext(savepath)[0] + ".tif";
  IJ.saveAsTiff(imp, savepath)
  imp.close()


listOfInputs = input.split("zzzzz")
srcFile = listOfInputs[0]
dstFile = listOfInputs[1]
ext = listOfInputs[2]
print(srcFile)
run()

System.exit(0);
