#!/bin/bash
start_time=$(date +%s%3N)
input_dir="$1"
if [[ -z "$input_dir" ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi
if [[ ! -d "$input_dir" ]]; then
    echo "Directory not found: $input_dir"
    exit 1
fi
process_file() {
    local input_file="$1"
    local output_file="${input_file%.csv}.html"
    echo '<table>' > "$output_file"
    echo '<tr>' >> "$output_file"
    header_line=$(head -n1 "$input_file" | tr -d '"')
    echo "$header_line" | tr ',' '\n' | while read header; do
        echo "<th>$header</th>" >> "$output_file"
    done
    echo '</tr>' >> "$output_file"
    IFS=',' read -r -a headers_array <<< "$header_line"
    url_column_index=-1
    for i in "${!headers_array[@]}"; do
        if [[ "${headers_array[$i]}" == "URL" ]]; then
            url_column_index=$i
            break
        fi
    done
    tail -n +2 "$input_file" | while IFS="," read -r -a line; do
        echo "<tr>" >> "$output_file"
        for i in "${!line[@]}"; do
            cell="${line[$i]}"
            if [[ $i -eq $url_column_index ]]; then
                cell="<a class='alink' href=\"$cell\" target='_blank'>$cell</a>"
            fi
            echo "<td>$(echo "$cell" | tr -d '"')</td>" >> "$output_file"
        done
        echo "</tr>" >> "$output_file"
    done
    echo '</table>' >> "$output_file"
}
for input_file in "$input_dir"/*.csv; do
    [[ -f "$input_file" ]] && process_file "$input_file"
done
end_time=$(date +%s%3N)
execution_time=$((end_time - start_time))
echo "Execution time: $execution_time milliseconds"