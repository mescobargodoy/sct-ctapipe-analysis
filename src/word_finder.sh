#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file_to_find_word> <word_next_param>" 
    exit 1
fi
# Define the file path
file_path="$1"
word_next_to_param="$2"
# Read the file line by line
while IFS= read -r line; do
    # Check if the line contains "CleaningMethod"
    if [[ $line == *"$word_next_to_param"* ]]; then
        # Extract the word next to "CleaningMethod"
        some_word=$(echo "$line" | awk '{print $2}')
        # Exit the loop after the first occurrence if needed
        break
    fi
done < "$file_path"
echo "$some_word"