#!/bin/bash

# Check if correct number of arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <input_file> <replacement_file> <output_file>"
    exit 1
fi

input_file="$1"
replacement_file="$2"
output_file="$3"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file '$input_file' not found."
    exit 1
fi

# Check if replacement file exists
if [ ! -f "$replacement_file" ]; then
    echo "Replacement file '$replacement_file' not found."
    exit 1
fi

# Process replacement file and store replacements in associative array
declare -A replacements
start_reading=false
while IFS= read -r line || [ -n "$line" ]; do
    # Start reading from the line after the comment "# Start reading from here"
    if [[ "$line" =~ ^\#.*Start\ reading\ from\ here ]]; then
        start_reading=true
        continue
    fi

    # Ignore commented lines, empty lines, and lines before the start comment
    if [ "$start_reading" = true ] && [ -n "$line" ] && [[ ! "$line" =~ ^\# ]]; then
        old_word=$(echo "$line" | awk '{print $1}')
        new_word=$(echo "$line" | awk '{print $2}')
        replacements["$old_word"]="$new_word"
    fi
done < "$replacement_file"

# Perform replacements in input file and write to output file
while IFS= read -r line || [ -n "$line" ]; do
    for old_word in "${!replacements[@]}"; do
        new_word="${replacements["$old_word"]}"
        line="${line//$old_word/$new_word}"
    done
    echo "$line" >> "$output_file"
done < "$input_file"

echo "Replacements completed. Output written to '$output_file'."
