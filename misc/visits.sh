#!/bin/bash
echo "Content-Type: text/plain"
echo ""
FILE="visits.txt"
if [[ ! -f "$FILE" ]]; then
    echo 0 > "$FILE"
fi
NUMBER=$(<"$FILE")
((NUMBER++))
echo "$NUMBER" > "$FILE"