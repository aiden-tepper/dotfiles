#!/bin/bash

CONF="$HOME/.config/wallpaper/wallpaper.conf"
CUR_HOUR=$(date +%H)

# Extract the parent directory
BASE_DIR=$(grep "^DIR=" "$CONF" | cut -d'=' -f2)

# Find the matching range
# This handles the wrap-around for night (e.g., 20 to 06)
IMG=$(awk -v h="$CUR_HOUR" -F'|' '
    /^DIR=/ {next}
    /^#/ {next}
    {
        start=$1; end=$2; file=$3;
        if ((start < end && h >= start && h < end) || 
            (start > end && (h >= start || h < end))) {
            print file; exit
        }
    }
' "$CONF")

if [ -n "$IMG" ]; then
    qs -c noctalia-shell ipc call wallpaper set "$BASE_DIR/$IMG" all
else
    echo "No matching time range found for hour $CUR_HOUR"
fi
