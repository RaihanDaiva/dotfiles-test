#!/bin/bash
# 🖼️ APPLY SELECTED WALLPAPER FILE WITH 60FPS SMOOTH ANIMATION (AWWW / SWWW / HYPRPAPER)
FULL_PATH="$1"

if [ -z "$FULL_PATH" ] || [ ! -f "$FULL_PATH" ]; then
    echo "Error: Invalid wallpaper path '$FULL_PATH'"
    exit 1
fi

CACHE_PATH="$HOME/.cache/current_wallpaper.jpg"
FILENAME=$(basename "$FULL_PATH")

echo "Applying wallpaper with smooth transition: $FULL_PATH"

# 1. Update shortcut link 'current_wallpaper.jpg'
ln -sf "$FULL_PATH" "$CACHE_PATH"

# 2. Execute 60FPS Smooth Wayland Animation Renderer (awww / swww)
if command -v awww >/dev/null 2>&1; then
    if ! pgrep -x "awww-daemon" >/dev/null; then
        awww-daemon &
        sleep 0.3
    fi
    awww img "$CACHE_PATH" --transition-type outer --transition-fps 60 --transition-duration 1.2 >/dev/null 2>&1
elif command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl hyprpaper unload all 2>/dev/null || true
    hyprctl hyprpaper preload "$CACHE_PATH" 2>/dev/null || true
    hyprctl hyprpaper wallpaper ",$CACHE_PATH" 2>/dev/null || true
elif command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$CACHE_PATH" -m fill >/dev/null 2>&1 &
fi

# 3. Update Pywal Theme Colors & Broadcast to Terminals
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
        if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
            hyprctl keyword general:col.active_border "$color11 $color14 45deg" 2>/dev/null || true
            hyprctl keyword general:col.inactive_border "$color1" 2>/dev/null || true
        fi
    fi
fi

# 4. Reload Cava audio visualizer
if pgrep -x "cava" > /dev/null; then
    pkill -USR1 cava 2>/dev/null || true
fi

# 5. Desktop Notification
notify-send "Wallpaper Changed" "$FILENAME" -i "$FULL_PATH" 2>/dev/null || true
