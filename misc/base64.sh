#!/bin/bash
image_path=$FILE_PATH
if [ ! -f "$image_path" ]; then
	echo "Content-type: text/plain"
	echo ""
	echo "File not found: $image_path"
	exit 1
fi
echo "Content-type: text/plain"
echo ""
base64 "$image_path"