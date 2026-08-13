#!/bin/bash
# 🖼️ APPLY SELECTED WALLPAPER FILE WITH 60FPS ANIMATION (AWWW) + BLURRED BACKDROP (SWAYBG TEKNIK 2)
FULL_PATH="$1"

if [ -z "$FULL_PATH" ] || [ ! -f "$FULL_PATH" ]; then
    echo "Error: Invalid wallpaper path '$FULL_PATH'"
    exit 1
fi

CACHE_PATH="$HOME/.cache/current_wallpaper.jpg"
BLUR_CACHE_PATH="$HOME/.cache/blurred_wallpaper.jpg"
FILENAME=$(basename "$FULL_PATH")

echo "Applying wallpaper with smooth transition: $FULL_PATH"

# 1. Update shortcut link 'current_wallpaper.jpg'
ln -sf "$FULL_PATH" "$CACHE_PATH"

# 2. Render Crisp Wallpaper on Workspaces (awww / hyprpaper)
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
fi

# 3. Teknik 2 Niri: Generate & Render Blurred Wallpaper on Overview Backdrop (swaybg)
if command -v magick >/dev/null 2>&1 && command -v swaybg >/dev/null 2>&1; then
    magick "$CACHE_PATH" -resize 50% -blur 0x25 "$BLUR_CACHE_PATH" 2>/dev/null || cp "$CACHE_PATH" "$BLUR_CACHE_PATH"
    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$BLUR_CACHE_PATH" -m fill >/dev/null 2>&1 &
elif command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$CACHE_PATH" -m fill >/dev/null 2>&1 &
fi

# 4. Update Pywal Theme Colors & Broadcast to Terminals
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

    # Update Active Window Border Colors Directly in 20-layout-and-overview.kdl & Hyprland
    if [ -f "$HOME/.cache/wal/colors.sh" ]; then
        source "$HOME/.cache/wal/colors.sh"

        NIRI_LAYOUT_CONF="$HOME/.config/niri/config.d/20-layout-and-overview.kdl"
        if [ -f "$NIRI_LAYOUT_CONF" ]; then
            sed -i -E '/focus-ring \{/,/}/ s/active-gradient from="[^"]+" to="[^"]+" angle=45/active-gradient from="'"$color11"'" to="'"$color14"'" angle=45/g' "$NIRI_LAYOUT_CONF"
            if command -v niri >/dev/null 2>&1; then
                niri msg action load-config-file >/dev/null 2>&1 || true
            fi
        fi

        if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
            hyprctl keyword general:col.active_border "$color11 $color14 45deg" >/dev/null 2>&1 || true
            hyprctl keyword general:col.inactive_border "$color1" >/dev/null 2>&1 || true
        fi
    fi
fi

# 5. Reload Cava audio visualizer
if pgrep -x "cava" > /dev/null; then
    pkill -USR1 cava 2>/dev/null || true
fi

# 6. Desktop Notification
notify-send "Wallpaper Changed" "$FILENAME" -i "$FULL_PATH" 2>/dev/null || true
