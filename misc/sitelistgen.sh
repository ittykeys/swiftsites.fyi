#!/bin/bash
start_time=$(date +%s%3N)
input_file="$1"
if [[ -z "$input_file" ]]; then
    echo "Usage: $0 <file>"
    exit 1
fi
if [[ ! -d "$input_file" ]]; then
    echo "File not found: $input_file"
    exit 1
fi

process_file "$input_file"

end_time=$(date +%s%3N)
execution_time=$((END_TIME - start_time))
echo "Execution time: $execution_time milliseconds"