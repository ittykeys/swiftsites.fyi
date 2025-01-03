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
    mod_date=$(date -r "$input_file" +"%Y-%m-%dT%H:%M:%S")
    readable_mod_date=$(date -r "$input_file" +"%B %d %Y %I:%M %p")

    # Write the datetime and opening table tag
    {
        echo "<time datetime=\"$mod_date\">Updated: $readable_mod_date</time>"
        echo '<table>'
    } > "$output_file"

    # Process the CSV file using awk
    awk -v output="$output_file" '
    BEGIN {
        FS = ","; OFS = "";
    }
    NR == 1 {
        print "<tr>" >> output;
        for (i = 1; i <= NF; i++) {
            gsub("\"", "", $i);  # Remove quotes
            headers[i] = $i;     # Store headers
            if ($i == "URL") url_col_idx = i;
            print "<th>" $i "</th>" >> output;
        }
        print "</tr>" >> output;
    }
    NR > 1 {
        print "<tr>" >> output;
        for (i = 1; i <= NF; i++) {
            gsub("\"", "", $i);  # Remove quotes
            if (i == url_col_idx) {
                print "<td><a class=\"alink\" href=\"" $i "\" target=\"_blank\">" $i "</a></td>" >> output;
            } else {
                print "<td>" $i "</td>" >> output;
            }
        }
        print "</tr>" >> output;
    }
    END {
        print "</table>" >> output;
    }' "$input_file"
}
for input_file in "$input_dir"/*.csv; do
    [[ -f "$input_file" ]] && process_file "$input_file" &
done
end_time=$(date +%s%3N)
execution_time=$((end_time - start_time))
echo "Execution time: $execution_time milliseconds"