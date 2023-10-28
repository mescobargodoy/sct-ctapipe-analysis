#!/bin/bash
# Some code borrowed from chatgpt
# Check if the correct number of arguments are provided
if [ $# -lt 5 ]; then
  echo "Usage: $0 <input_script> <output_script> <old_word_1> <new_word_1> <old_word_2> <new_word_2>"
  echo "Configures cleaning parameters in ctapipe config file."
  exit 1
fi

input_script="$1"
output_script="$2"

# Extract old_word and new_word pairs from the arguments
shift 2  # Remove the first two arguments (input_script and output_script)
replace_pairs=()
while [ $# -gt 0 ]; do
  old_word="$1"
  new_word="$2"
  replace_pairs+=("-e s/$old_word/$new_word/g")
  shift 2
done

# Check if the input script file exists
if [ ! -f "$input_script" ]; then
  echo "Input script not found: $input_script"
  exit 1
fi

# Use sed to perform multiple word replacements and save the result to the output file
sed "${replace_pairs[@]}" "$input_script" > "$output_script"

echo "Words replaced and script saved to $output_script"
