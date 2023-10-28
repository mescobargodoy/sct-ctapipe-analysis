#!/bin/bash

cleaning_params() {
    local name=""
    for arg in "$@"; do
        name+="${arg}_"
    done
    echo "${name%_}"
}

# Check if there are at least three arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 arg1 arg2 arg3 [arg4 ...]"
    exit 1
fi

# Example usage with command-line arguments
result=$(cleaning_params "$@")
echo $result