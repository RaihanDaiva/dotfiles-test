#!/bin/bash
# restore-wallpaper.sh
# Dipanggil saat boot untuk me-restore wallpaper terakhir (awww) + blurred backdrop (swaybg) & warna pywal

CACHE_PATH="$HOME/.cache/current_wallpaper.jpg"
BLUR_CACHE_PATH="$HOME/.cache/blurred_wallpaper.jpg"

if [ ! -e "$CACHE_PATH" ]; then
    echo "restore-wallpaper: $CACHE_PATH tidak ditemukan, skip."
    exit 0
fi

REAL_PATH=$(readlink -f "$CACHE_PATH")
echo "restore-wallpaper: Memulihkan wallpaper -> $REAL_PATH"

# 1. Restore Crisp Workspace Wallpaper (awww / hyprpaper)
if command -v awww >/dev/null 2>&1; then
    if ! pgrep -x "awww-daemon" >/dev/null; then
        awww-daemon &
        sleep 0.3
    fi
    awww img "$CACHE_PATH" --transition-type outer --transition-fps 60 --transition-duration 1.0 >/dev/null 2>&1
elif command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl hyprpaper unload all 2>/dev/null || true
    hyprctl hyprpaper preload "$CACHE_PATH" 2>/dev/null || true
    hyprctl hyprpaper wallpaper ",$CACHE_PATH" 2>/dev/null || true
fi

# 2. Restore Teknik 2 Blurred Overview Backdrop Wallpaper (swaybg)
if command -v magick >/dev/null 2>&1 && command -v swaybg >/dev/null 2>&1; then
    if [ ! -f "$BLUR_CACHE_PATH" ]; then
        magick "$CACHE_PATH" -resize 50% -blur 0x25 "$BLUR_CACHE_PATH" 2>/dev/null || cp "$CACHE_PATH" "$BLUR_CACHE_PATH"
    fi
    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$BLUR_CACHE_PATH" -m fill >/dev/null 2>&1 &
elif command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$CACHE_PATH" -m fill >/dev/null 2>&1 &
fi

# 3. Restore Pywal Colors & Border Colors for Niri & Hyprland
if command -v wal > /dev/null 2>&1; then
    wal -R -q --noswallow 2>/dev/null || wal -i "$REAL_PATH" -q 2>/dev/null
    if [ -f "$HOME/.cache/wal/sequences" ]; then
        for pts in /dev/pts/[0-9]*; do
            cat "$HOME/.cache/wal/sequences" > "$pts" 2>/dev/null || true
        done
    fi
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
            hyprctl keyword general:col.active_border "$color11 $color14 45deg" 2>/dev/null || true
            hyprctl keyword general:col.inactive_border "$color1" 2>/dev/null || true
        fi
    fi
fi
