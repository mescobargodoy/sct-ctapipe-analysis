# Bash scripts for processing multiple simtel files using ctapipe

[ctapipe](https://ctapipe.readthedocs.io/en/stable/index.html) is a "low-level data processing pipeline software for CTA (the [Cherenkov Telescope Array](https://www.cta-observatory.org/))". The series of scripts in this repository utilize ctapipe command-line tools to process multiple simulation files at once. Two ctapipe applications are used here, namely *ctapipe-procees* and *ctapipe-merger*. At the time being, ctapipe-process only takes a single file. These scripts were made to submit multiple ctapipe-process jobs at once and allow users to process multiple files at once. 

Not all *ctapipe-process* options are included here and this was created only to process simulation files containing a sinle telescope type (the Schwarzchild-Couder Telescope to be more specific but any single telescope simulation file should in principle work). *ctapipe-process* allows you to go from R0->DL3 although for the scripts in this repository you can only go up to DL2. For more on data levels see [here](https://ctapipe.readthedocs.io/en/stable/api/ctapipe.io.DataLevel.html) 

For any ctapipe license or citing see [here](https://github.com/cta-observatory/ctapipe).

## Installation

Use the package manager [conda](https://docs.conda.io/projects/conda/en/stable/) or [pip](https://pip.pypa.io/en/stable/) to install ctapipe which is required.
The ctapipe version used to develop these scripts was 0.19.2. The scripts haven't been tested with any other versions. Keep in mind ctapipe is still in development so things can change rather quickly and these scripts might not work for older or new versions.

```bash
conda install conda-forge::ctapipe 
```
or
```bash
pip install ctapipe
```
and then clone this repository.

## General description of the usage of this repo
1. User provides configuration file with user’s machine information (simulation files location, output directory, …) and *ctapipe* parameters.
1. Upon script execution temporary configuration file (and temporary h5 files if MergeH5Files flag is set to True) are created to get passed to *ctapipe-process* and *ctapipe-merge*. Eventually temporary configuration (and temporary h5 files) files are deleted. 
1. *ctapipe-process* jobs are submitted.
1. *ctapipe-merge* merges files (optional).
1. Logs, provenance and h5 files are written to specified output directory.


## Usage
First export the path where you cloned this repository in your bashrc or bash_profile.

```bash
export SCTCTAPIPEANALYSISDIR=/path_to_this_repo
export PATH=$PATH:$SCTCTAPIPEANALYSISDIR
```
and then source bashrc or bash_profile. You should be able to execute scripts from anywhere now.

Then set up the configuration file. For a more verbose description of the parameters read CONFIGREADME.md.

The file *config_sample.inst* contains most of the options specified but the user will need to specify the input directory with the simulation files, output directory for data products, number of cores in your machine, and user information. Any text file having the format of multictapipeprocess_configuration_file_sample.inst should work. All options need to be specified and none can be left blank. 

Once the config file is filled out do
```bash
multictapipeprocess.sh config_sample.inst
```
There will be three products written to the output directory. The products are logs, [provenance](https://ctapipe.readthedocs.io/en/stable/auto_examples/core/provenance.html) and h5 files which are the files containing analyzed data. 

Provenance "tracks both input and output files, as well as details of the machine and software environment on which a Tool executed".


## Variation of cleaning parameters
There is an additional script *multictapipeprocess_cleaning.sh* that allows you to submit multiple ctapipe-process jobs with different cleaning parameters. All the other parameters remain fixed. Sample configuration files are provided: *config_cleaning_sample.inst* and 
*cleaning_params_sample.inst*.

Once the configuration files are filled out do
```bash
multictapipeprocess_cleaning.sh config_cleaning_sample.inst cleaning_params_sample.inst
```
and the output will follow the same format as before.

Suppose you decide to use FACTImageCleaner (a cleaning algorithm that applies two charge cuts and one time cut) and wish to vary it, you can set up the *cleaning_params_sample.inst* would as follows: 
```bash
image_pe_values=(2.5 3.5)           # Image pixels photoelectron cut [pe]
neighbor_pe_values=(1.5 2.5)        # Neighbor pixels photoelectron cut [pe]
delta_t_values=(1.0 2.0)            # Time difference between neigbors [ns]
```
The first value of each list would correspond to the cleaning parameters used for the first run of ctapipe-process and the second value of each list would correspond to the cleaning parameters used for the second run of ctapipe process.

The *image_pe*, *neighbor_pe* and *delta_t* values are no longer an option in *config_cleaning_sample.inst*. They need to be specified in *cleaning_params_sample.inst*. Any files that follow the format of these config files two will work.

## Output structure
The output files will have a naming convention based on the cleaning method and cleaning parameters as used as well as the file type.
For a given simulation file, say *myfile.simtelgz* the output files will be
```bash
/outputdirectory/myfile_cleaningmethod_chargecut1_chargecut2_timecut.h5
/outputdirectory/logs/process/myfile_cleaningmethod_chargecut1_chargecut2_timecut.log
/outputdirectory/provenance/process/myfile_cleaningmethod_chargecut1_chargecut2_timecut.prov
```

For a more concrete example, if your input directory has the following files
```bash
gamma_20deg_0deg_run838___cta-prod3-sct_desert-2150m-Paranal-SCT.simtel.gz
gamma_20deg_0deg_run868___cta-prod3-sct_desert-2150m-Paranal-SCT.simtel.gz
```
 and you decide to use the FACTImageCleaner (charge and time cuts) with values 2.5 pe, 1.5 pe, 1.0 ns as cleaning parameters, the output will be (assuming no merging of files):
 ```bash
/outputdirectory/gamma_20deg_0deg_run838___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.h5
/outputdirectory/gamma_20deg_0deg_run868___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.h5

/outputdirectory/logs/process/gamma_20deg_0deg_run838___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.log
/outputdirectory/logs/process/gamma_20deg_0deg_run868___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.log

/outputdirectory/provenance/process/gamma_20deg_0deg_run838___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.h5
/outputdirectory/provenance/process/gamma_20deg_0deg_run868___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.h5
 ```  
If you decided to merge these two files into a single one the outputs would look like:
```bash
/outputdirectory/gamma_20deg_0deg____cta-prod3-sct_desert-2150m-Paranal-SCT_merged_dl2_2pass_2.5_1.5.h5

/outputdirectory/logs/mergers/gamma_20deg_0deg____cta-prod3-sct_desert-2150m-Paranal-SCT_merged_dl2_2pass_2.5_1.5.log
/outputdirectory/logs/process/gamma_20deg_0deg_run838___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.log
/outputdirectory/logs/process/gamma_20deg_0deg_run868___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.log

/outputdirectory/provenance/mergers/gamma_20deg_0deg____cta-prod3-sct_desert-2150m-Paranal-SCT_merged_dl2_2pass_2.5_1.5.prov
/outputdirectory/provenance/process/gamma_20deg_0deg_run838___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.prov
/outputdirectory/provenance/process/gamma_20deg_0deg_run868___cta-prod3-sct_desert-2150m-Paranal-SCT_FACT_2.5_1.5_1.0.prov
```

# Extra comments
I haven't tested these scripts extensively nor are all ctapipe options included here. Mainly reaching DL3 data products is not implemented nor processing of h5 files. In addition, user specified configuration file is based on my own definition of variables not the ones defined in ctapipe. I tried to use a descriptive naming convention that resembles ctapipe parameter names. Feel free to raise any issues, comments, suggestions or questions. Many things can be improved and extra things can be added.

# Contact
Miguel Escobar Godoy

email: mescob11@ucsc.edu