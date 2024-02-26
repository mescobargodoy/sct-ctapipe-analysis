#!/bin/bash

# Check if correct number of arguments are provided
if [ $# -lt 4 ]; then
    echo "Usage: $0 <input_dir> <output_dir> <n_cores> <config_file_1> <config_file_2> <config_file_3> ... <config_file_N>" 
    echo "input_dir: path to simulation files in .simtel.gz or .h5 format"
    echo "output_dir: path to place data products (logs, provenance, h5)"
    echo "n_cores: number of cores available in your machine"
    echo "config_file: ctapipe-specific configuration file(s) to process your files"
    echo "This scripts submits multiple ctapipe-process jobs at once."
    exit 1
fi

input_dir="$1"
output_dir="$2"
n_cores="$3"
config_file_1="$4"

echo "$input_dir $output_dir $n_cores $config_file_1"


config_params=()
index=5
while [ $index -le $# ]; do
    var_name="param$index"
    config_params+=("--config" "${!var_name}")
    ((index++))
done

# index=5
# for param in "${@:5}"; do
#     var_name="config_file_$index"
#     declare "$var_name=$param"
#     ((index++))
# done

# Specify directory to find simulation files as well as pattern
simtel_files_string=$(find "$input_dir" -name '*.simtel.gz' -type f)
IFS=$'\n' read -r -d '' -a simtel_files <<< "$simtel_files_string"

# Create logs and provenance directories
mkdir -p "${output_dir}logs/"
mkdir -p "${output_dir}provenance/"
output_process_logs_dir="${output_dir}logs/process/"
provenance_process_dir="${output_dir}provenance/process/"
mkdir -p "$output_process_logs_dir"
mkdir -p "$provenance_process_dir"


# Initializing cores being used to zero. It will increase by 1 as ctapipe-process job is submitted. Max value allowed is n_cores.
cores_used=0

echo "Starting ctapipe-process..."
# Iterating over all the simulation files in input directory
for file in "${simtel_files[@]}"; do
    # Logs, provenance, and h5 file naming
    name=$($SCTCTAPIPEANALYSISDIR/src/name_output_file.sh "$file" ".h5" ".simtel.gz" "True")
    log_=$($SCTCTAPIPEANALYSISDIR/src/name_output_file.sh "$file" ".log" ".simtel.gz" "True")
    prov_=$($SCTCTAPIPEANALYSISDIR/src/name_output_file.sh "$file" ".prov" ".simtel.gz" "True")
    log="$output_process_logs_dir$log_"
    prov="$provenance_process_dir$prov_"
    output_file="$output_dir$name"
    
    # Submitting ctapipe-process jobs
    ctapipe-process --input "$file" --o "$output_file" --l "$log" --provenance-log="$prov" --config "$config_file_1" "${config_params[@]}" --progress &
    cores_used=$((cores_used + 1))
    echo "$cores_used file(s) being processed."

    # Checking if maximum number of jobs submitted equals number of cores. If it does it will wait until jobs are done. 
    if [ "$cores_used" -eq "$n_cores" ]; then
        echo "Maximum number of files being analyzed. Waiting for jobs to finish."
        wait
        cores_used=0
        echo "Done. Continuing ctapipe-process."
    fi
done
wait
echo "ctapipe-process done."