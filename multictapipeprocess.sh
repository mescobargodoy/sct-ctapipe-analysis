#!/bin/bash
# Working so far!

# Check if correct number of arguments are provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <ctapipe_process_config_file>"
    exit 1
fi

#############################################################################################################################

ctapipe_process_config_file="$1"
input_dir=$(grep 'input_dir=' "$ctapipe_process_config_file" | cut -d'=' -f2 | tr -d ' ')
output_dir=$(grep 'output_dir=' "$ctapipe_process_config_file" | cut -d'=' -f2 | tr -d ' ')
n_cores=$(grep 'n_cores=' "$ctapipe_process_config_file" | cut -d'=' -f2)
merge_h5_files=$(grep 'merge_h5_files=' "$ctapipe_process_config_file" | cut -d'=' -f2)
cleaning_algorithm=$(./src/word_finder.sh "$ctapipe_process_config_file" 'CleaningMethod')

###############################################################################################################################

# # Default skeleton script
if [ "$cleaning_algorithm" = "TailCutsImageCleaner" ] || [ "$cleaning_algorithm" = "MARSImageCleaner" ]; then
    skeleton_configfile='src/charge_cuts_only_config_skelly.yaml'
elif [ "$cleaning_algorithm" = "FACTImageCleaner" ]; then
    skeleton_configfile='src/charge_cuts_and_timing_config_skelly.yaml'
    cleaning_name='FACT'
else 
    skeleton_config_file='src/charge_cuts_only_config_skelly.yaml'
    cleaning_name='2pass'
fi

if [ "$cleaning_algorithm" = "TailCutsImageCleaner" ]; then
    cleaning_name='2pass'
elif [ "$cleaning_algorithm" = "MARSImageCleaner" ]; then
    cleaning_name='MARS'
fi

# Specify directory to find simulation files as well as pattern
simtel_files_string=$(find "$input_dir" -name '*.simtel.gz' -type f)
IFS=$'\n' read -r -d '' -a simtel_files <<< "$simtel_files_string"

# Create temporary directory
mkdir -p temp
# Bash script to generate temporary config file
./src/fill_file_from_config.sh "$skeleton_configfile" "$ctapipe_process_config_file" 'temp/temp_config.yaml' 

# Create logs and provenance directories
mkdir -p "${output_dir}logs/"
mkdir -p "${output_dir}provenance/"
output_process_logs_dir="${output_dir}logs/process/"
provenance_process_dir="${output_dir}provenance/process/"
mkdir -p "$output_process_logs_dir"
mkdir -p "$provenance_process_dir"
    
# Find the cleaning parameters from .yaml file
first_pass=$(./src/word_finder.sh "$ctapipe_process_config_file" 'image_pe')
second_pass=$(./src/word_finder.sh "$ctapipe_process_config_file" 'neighbor_pe')
time_lim=$(./src/word_finder.sh "$ctapipe_process_config_file" 'delta_time')
# Append the cleaning parameters used to .h5 output file.
if [ "$cleaning_algorithm" = "TailCutsImageCleaner" ] || [ "$cleaning_algorithm" = "MARSImageCleaner" ]; then
    cleaningparams=$(./src/cleaning_params.sh "$cleaning_name" "$first_pass" "$second_pass")
elif [ "$cleaning_algorithm" = "FACTImageCleaner" ]; then
    cleaningparams=$(./src/cleaning_params.sh "$cleaning_name" "$first_pass" "$second_pass" "$time_lim")
fi
    
# Starting ctapipe-process section

cores_used=0 # TO DO: Check to see if there is a smart way to submit jobs that already check the number of cores being used.

for file in "${simtel_files[@]}"; do
# Temp file naming
    filename_end="dl2_$cleaningparams.h5"
    name=$(./src/name_output_file.sh "$file" "$filename_end" ".simtel.gz")
# Log and provenance file naming
    log_=$(./src/name_output_file.sh "$file" "log" ".simtel.gz")
    prov_=$(./src/name_output_file.sh "$file" "prov" ".simtel.gz")
    log="$output_process_logs_dir$log_"
    prov="$provenance_process_dir$prov_"

    # Submitting ctapipe-process jobs

    if [ "$merge_h5_files" = "True" ]; then
        temp_output_file="temp/$name"
        ctapipe-process --config 'temp/temp_config.yaml' --input "$file" --SimtelEventSource.focal_length_choice "$focal_length_choice" --o "$temp_output_file" --l "$log" --provenance-log="$prov" --progress &
        cores_used=$((cores_used + 1))           
        echo "$cores_used core(s) in use."
    else
        output_file="$output_dir$name"
        ctapipe-process --config 'temp/temp_config.yaml' --input "$file" --SimtelEventSource.focal_length_choice "$focal_length_choice" --o "$output_file" --l "$log" --provenance-log="$prov" --progress &
        cores_used=$((cores_used + 1))
        echo "$cores_used core(s) in use."
    fi 
        
    if [ "$cores_used" -eq "$n_cores" ]; then # check this conditional
        echo "Maximum number of cores in use. Waiting for job to finish."
        wait
        cores_used=0
        echo "Done. Continuing ctapipe-process."
    fi

done
wait
echo "ctapipe-process done."

# ctapipe-merge starts here.
if [ "$merge_h5_files" = "True" ]; then
    echo "Merging h5 files with $cleaningparams cleaning parameters."
    # Creating directories for merger logs and provenance files.
    output_mergers_logs_dir="${output_dir}logs/mergers/"
    provenance_mergers_dir="${output_dir}provenance/mergers/"
    mkdir -p "$output_mergers_logs_dir"
    mkdir -p "$provenance_mergers_dir"
    # Naming merged file
    merged_temp_name="${simtel_files[${#simtel_files[@]}-1]}"
    output_merged_file_=$(./src/name_output_file.sh "$merged_temp_name" "merged_$filename_end" ".simtel.gz")
    output_merged_file=$(echo "$output_merged_file_" | sed 's/run[0-9]*//')
    output_merged_file="$output_dir$output_merged_file"
    echo "Files merged into: $output_merged_file"
    # Naming merger logs and provenance files
    merged_log_=$(./src/name_output_file.sh "$output_merged_file" "log" ".h5")
    merged_prov_=$(./src/name_output_file.sh "$output_merged_file" "prov" ".h5")
    merged_log="$output_mergers_logs_dir$merged_log_"
    merged_prov="$provenance_mergers_dir$merged_prov_"

    # Merge files in temp directory
    search_pattern="*$filename_end"

    ctapipe-merge --input-dir 'temp/' --output "$output_merged_file" --pattern "$search_pattern" --l "$merged_log" --provenance-log="$merged_prov" --progress
    wait
fi
    
echo "ctapipe-merge done. Deleting temp folder."
# Delete anything left in the temp/ folder
rm -rf temp/
# done
