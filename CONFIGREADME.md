# Parameter description and options
The naming of the options for these scripts was named by myself (Miguel) but the descriptions of the parameters they correspond to come from
Most of this information can be found by using
```bash
ctapipe-process --help-all
ctapipe-merger --help-all
```
as well from [here](https://ctapipe.readthedocs.io/en/stable/index.html).

## Input and output
**input_dir**: Directory that contains your simulation files. Provide absolute path and include trailing / <string>

**output_dir**: Directory where you want your data product. Provide absolute path and include trailing / <string>

**n_cores**: How many cores are avaialble to use. There is no core optimization but the scripts are set up to only submit ctapipe-process up to n_cores jobs.


## Contact information stored in provenance -> Doesn't seem to be working at the moment
**YourName**: Name of user using ctapipe-process. Seperate names with a dash <string>

**YourEmail**: Your email is only stored in provenance. <string>

**YourInstitution**: Name of institute/university. <string>


## Data writing parameters
Options here will specify whether you just want R0, R1, DL0, DL1 or DL2. For isntance, if WriteDL2StereoReco is set to False, shower reconstruction won't take place.

**OverWriteExistingFile**: If there is an existing file whether to overwrite or not <True/False>

**WriteDL1Images**: Whether to store images in file. Note it will take a lot of space and take time <True/False>

**WriteDL1Parameters**: Whether to write Hillas parameters <True/False>

**WriteDL2StereoReco**: Whether to perform and store stereo reconstruction information <True/False>

**WriteRawWaveforms**:  Whether to write uncalibrated waveforms to file <True/False>

**WriteCalibratedWaveforms**: Whether to write calibrated waveforms to file <True/False>

**WriteMuonParameters**: Whether to write muon parameters to file <True/False>

**FocalLengthChoice**: Available options are 'EQUIVALENT', 'EFFECTIVE',... Need 'EQUIVALENT' for prod3b

## Level of information included in logs 
Choices: any of [0, 10, 20, 30, 40, 50, 'DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL']
I haven't explored all the options here. Apply to the following: **Merge_Log_File_Level**, **Merge_Log_Level**, **LogFileLevel**, **LogLevel**

# ctapipe-merger parameters
**MergeH5Files**: Whether to merge files at the end. Note individual files are deleted and only merged is kept. <True/False>

**OverWriteExistingMergerFile**: If merged file exists already, whether to replace <True/False>

**SkipBrokenFiles**: When merging, if there is a broken file it won't include it in merger <True/False>

**AppendtoExistingFile**: If true, the ``output_path`` is appended to <True/False>    

**IncludeDL1Images**: Whether to include DL1 images (if any) in merger of files <True/False>

**IncludeDL1Muon**: Whether to include Muon parameters (in any) when merging <True/False>

**IncludeHillasParams**: Whether to include Hillas parameters (if any) when merging <True/False>

**IncludeDL2SubarrayEventWiseData**: Whether to include gamma-ray event array level DL2 data (if any) <True/False>

**IncludeDl2TelescopeEventWiseData**: Whether to include telescope-wise DL2 data (if any) <True/False>

**IncludeMonitoringData**: Not entirely sure what this is

**IncludeProcessingStatistics**: Whether to include processing statistics <True/False>

**IncludeDatawithSimulationOnly**: Whether to include data with simulation available <True/False>

**IncludeTelescopeWiseData**: <True/False>

**IncludeTrueImages**: Whether to include true images (if any) <True/False>

**IncludeTrueParameters**: Whether to include Hillas parameters (if any) calculated using true images <True/False>

## Charge extraction
More details regarding waveform integration can be found [here](https://ctapipe.readthedocs.io/en/stable/api-reference/image/extractor.html#image-extraction-methods). 

**ChargeExtraction**: Waveform integration method. Available methods are: 'FullWaveformSum', 'FixedWindowSum', 'GlobalPeakWindowSum','LocalPeakWindowSum','SlidingWindowMaxSum', 'NeighborPeakWindowSum', 'TwoPassWindowSum', 'BaselineSubtractedNeighborPeakWindowSum'


## Telescope parameters
**UseTelescopeFrame**: Whether to use telescope of camera frame <True/False>

**TelescopeType**: Which telescope to use for instance MST*SCTCam

## Image Quality Criteria
If quality criteria is met, the images are parameterized.                      
**KeepIsolatedPixels**: If False, pixels with < min_pic_neighbors are removed. <True/False>

**MinimumPictureNeighbors**: Minimum number of neighbor pixels above neighbor pe cut to consider <integer>

**MinimumPixelsInImage**: Minimum # of pixels in image required to be considered for analysis <integer>

**MinimumImageSize**: Minimum total charge [pe] in image required to be considered for analysis <integer>

## Image Cleaning
More on cleaning algorithms [here](https://ctapipe.readthedocs.io/en/stable/api-reference/image/cleaning.html).

**CleaningMethod**: Cleaning algorithm to use. The choices are TailcutsImageCleaner, MARSImageCleaner, FACTImageCleaner

## Stereo geometry reconstructor 
**StereoGeometryReconstructor**: options are HillasReconstructor and HillasIntersection. Haven't tested others.


## Stereo quality criteria - 
Images with Hillas parameters satisfying quality criteria stated here are used. Not implemented - do not know ideal parameters

**HillasSize**: Require Hillas size greater than this value. Size is another word for total integrated charge after image cleaning. <float>

**HillasWidth**: Require Hillas width greater than this value. Generally width refers to small axis of fitted ellipse over shower image in camera. <float>

**HillasMininumPixelsInImage**: Minimum # of pixels in image required to be considered for analysis <int>

**HillasDistance**: Require Hillas distance less than this quantity in degrees <float>