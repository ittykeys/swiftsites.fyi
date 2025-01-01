#!/bin/bash
echo "Content-Type: text/plain"
echo ""
CSS_FILE="../css/vars.css"
SVG_FILE="../img/logo.svg"
COLOR=$(grep -- "--orange:" "$CSS_FILE" | sed -E 's/.*--orange: (#[A-Fa-f0-9]+);/\1/')
if [[ -z "$COLOR" ]]; then
  echo "Error: Color variable --orange not found in $CSS_FILE"
  exit 1
fi
MODIFIED_SVG=$(sed -E 's/<path([^>]*?)d="/<path fill="'"$COLOR"'" \1d="/g' "$SVG_FILE")
echo "$MODIFIED_SVG" | tr -d '\n' | sed -e 's/"/%22/g' \
                                        -e "s/'/%27/g" \
                                        -e 's/</%3C/g' \
                                        -e 's/>/%3E/g' \
                                        -e 's/#/%23/g' \
                                        -e 's/{/%7B/g' \
                                        -e 's/}/%7D/g' \
                                        -e 's/|/%7C/g' \
                                        -e 's/\\/%5C/g' \
                                        -e 's/\^/%5E/g' \
                                        -e 's/`/%60/g' \
                                        -e 's/ /%20/g' \
                                        -e 's/@/%40/g'