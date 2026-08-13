#!/bin/bash
# 🖼️ SCAN WALLPAPERS ONLY FROM $HOME/.config/wallpapers DIRECTORY
WALL_DIR="$HOME/.config/wallpapers"

if [ -d "$WALL_DIR" ]; then
    find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | sort -u | while read -r file; do
        filename=$(basename "$file")
        title="${filename%.*}"
        # Clean up title formatting
        title=$(echo "$title" | sed 's/[-_]/ /g' | sed 's/  */ /g')
        echo "$filename|$file|$title"
    done
fi | sort -u -t'|' -k3,3
