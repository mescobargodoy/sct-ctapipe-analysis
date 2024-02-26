#!/bin/bash
# Check if the correct number of arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <file path> <output file name ending> <string to remove from file (optional)> <no_underscore (optional)>
        Removes any path dependencies from name as well as .simtel.gz. It also adds ending of your choice.
        <no_underscore>: True/False. If true no underscore is added.
        Example: 
        ./name_output_h5.sh simtel/array.simtel.gz some_ending.h5 .simtel.gz
        -> array_some_ending.h5
        
        or
        ./name_output_h5.sh simtel/array.simtel.gz some_ending.h5 .simtel.gz True
        -> arraysome_ending.h5" 
  exit 1
fi

file_path="$1"
output_file_ending="$2"
string_to_remove="$3"

temp_name=$(basename "$file_path")
base_name="${temp_name%$string_to_remove}"

result="$base_name"_"$output_file_ending"
if [ "$4" = "True" ]; then
  result="$base_name$output_file_ending"
fi

echo $result