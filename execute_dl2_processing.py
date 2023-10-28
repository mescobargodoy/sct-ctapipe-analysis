"""
First iteration of script that does parallel processing
of a set of simulation files with variation of the cleaning
parameters. 

It is very hard coded and taylored for the VHE machines at
UC Santa Cruz. The goal will be eventually for the user to just
provide the cleaning method plus params for the specified telescope
and the appropriate simulation files that contained
said telescope.
"""

import subprocess
import numpy as np
from helpers import*



# Default skeleton script
skeleton_configfile = 'config_skelly.yaml'

# Specify cleaning method for naming
cleaning_method = '2pass'

# Specify directory to find simulation files as well as pattern
simtel_files = findfiles('simtel_files/','.simtel.gz',True)

# Specify relative output directory
output_dir = 'cleaning_analysis_dl2_h5_files/two_pass_narrow/'

# TO-DO
# Write a function that loads in the files that will be processed
# in a list like fasion

# Define the the photoelectron thresholds in whatever fashion
image_pe = np.array([4.])#, 4.25, 4.5, 4.75])# np.linspace(2,5,17) # 
neighbor_pe=np.array([2.5 , 2.75, 3.25, 3.5 ,3.75])#, 4.25, 4.5])# np.linspace(1,4.5,15) # 


for im_pe in image_pe:
    for nei_pe in neighbor_pe:
        if im_pe>nei_pe:
            
            # create a temporary directory with subprocess module
            # to store dl2.h5 files to eventually merge and delete
            subprocess.run(["mkdir", "temp"])
            
            
            # Creating and configuring ctapipe-process config file
            first_pass = str(im_pe)      # image pixel
            second_pass = str(nei_pe)    # neighobor pixel
            
            # Submitting bash script to generate temporary config file
            subprocess.run(["./ctapipe_config_skelly.sh",
                            skeleton_configfile,
                            'temp/temp_config.yaml',
                            'image_pe',first_pass,
                            'neighbor_pe',second_pass])

            # Append this to .h5 file to know cleaning params used
            cleaningparams = cleaning_params(cleaning_method,
                                              first_pass,
                                              second_pass)
                        
            # Starting ctapipe-process section
            
            # iterator is used to make sure only the input simtel
            # files given are processed at a time (per cleaning config)
            # before advancing. Specific to vhe-machines to not
            # overload with jobs.
            
# TO DO
# Write smart enough algorithm that submits many jobs at once and knows
# how to merge them.
# Probably smart naming convention would do.
# Storing naming convention and then iterating over it to do merging

            iterator = 0
            
            for file in simtel_files:
                
                # Temp file naming
                filename_end = 'dl2_'+cleaningparams+'.h5'
                name = namesimtelfile(file,filename_end)
                tempoutputname='temp/'+name

                # Submitting ctapipe-process jobs
                process = subprocess.Popen(['ctapipe-process',
                                            '--config', 'temp/temp_config.yaml',
                                            '--input',file,
                                            '--SimtelEventSource.focal_length_choice', 'EQUIVALENT',
                                            '--o', tempoutputname,
                                            '--progress','&']
                                            )
                iterator+=1

                if iterator==len(simtel_files):
                    process.wait()
            
            # Naming merged file (to be improved)
            output_name = namesimtelfile(simtel_files[-1],'merged'+filename_end)
            output_name = removechars(output_name,'run')
            output_name = output_dir+output_name
            # Merge files in temp directory
            search_pattern = "*" + filename_end
            subprocess.run(['ctapipe-merge',
                            '--input-dir', 'temp/',
                            '--output', output_name,
                            '--pattern', search_pattern]
                            )

            # Delete files in temp
            subprocess.run(["rm", "-rf", "temp/"])
        else:
            break
# Delete anything left in the temp/ folder
subprocess.run(["rm", "-rf", "temp/"])
