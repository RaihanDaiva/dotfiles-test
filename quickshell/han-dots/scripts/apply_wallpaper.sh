#!/bin/bash
# 🖼️ APPLY SELECTED WALLPAPER FILE & UPDATE HYPRPAPER + PYWAL
FULL_PATH="$1"

if [ -z "$FULL_PATH" ] || [ ! -f "$FULL_PATH" ]; then
    echo "Error: Invalid wallpaper path '$FULL_PATH'"
    exit 1
fi

# 1. Auto-detect Hyprland Instance Signature if missing in subshell environment
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /tmp/hypr/ 2>/dev/null | head -n 1)
    export HYPRLAND_INSTANCE_SIGNATURE
fi

# 2. Ensure Hyprpaper daemon is running
if ! pgrep -x "hyprpaper" > /dev/null; then
    echo "Hyprpaper daemon is not running. Starting hyprpaper..."
    hyprpaper &
    sleep 1
fi

CACHE_PATH="$HOME/.cache/current_wallpaper.jpg"
FILENAME=$(basename "$FULL_PATH")

echo "Applying wallpaper: $FULL_PATH"

# 3. Update shortcut link 'current_wallpaper.jpg'
ln -sf "$FULL_PATH" "$CACHE_PATH"

# 4. Execute Hyprpaper unload, preload & set wallpaper
hyprctl hyprpaper unload all 2>/dev/null
hyprctl hyprpaper preload "$CACHE_PATH" 2>/dev/null
hyprctl hyprpaper wallpaper ",$CACHE_PATH" 2>/dev/null

# 5. Update Pywal Theme Colors & Broadcast to Terminals
if command -v wal >/dev/null 2>&1; then
    wal -i "$FULL_PATH" >/dev/null 2>&1
    if [ -f "$HOME/.cache/wal/colors-kitty.conf" ]; then
        cp "$HOME/.cache/wal/colors-kitty.conf" "$HOME/.config/kitty/current-theme.conf" 2>/dev/null || true
        cp "$HOME/.cache/wal/colors-kitty.conf" "$HOME/.config/kitty/theme.conf" 2>/dev/null || true
    fi
    if [ -f "$HOME/.cache/wal/sequences" ]; then
        for pts in /dev/pts/[0-9]*; do
            cat "$HOME/.cache/wal/sequences" > "$pts" 2>/dev/null || true
        done
    fi
    if [ -f "$HOME/.cache/wal/colors.sh" ]; then
        source "$HOME/.cache/wal/colors.sh"
        hyprctl keyword general:col.active_border "$color11 $color14 45deg" 2>/dev/null
        hyprctl keyword general:col.inactive_border "$color1" 2>/dev/null
    fi
fi

# 6. Reload Cava audio visualizer
if pgrep -x "cava" > /dev/null; then
    pkill -USR1 cava 2>/dev/null
fi

# 7. Desktop Notification
notify-send "Wallpaper Changed" "$FILENAME" -i "$FULL_PATH" 2>/dev/null

# 8. Reload Hyprland
hyprctl reload 2>/dev/null
