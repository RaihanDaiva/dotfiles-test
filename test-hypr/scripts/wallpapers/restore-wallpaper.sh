#!/bin/bash
# restore-wallpaper.sh
# Dipanggil saat boot untuk me-restore wallpaper terakhir & warna pywal

CACHE_PATH="$HOME/.cache/current_wallpaper.jpg"

if [ ! -e "$CACHE_PATH" ]; then
    echo "restore-wallpaper: $CACHE_PATH tidak ditemukan, skip."
    exit 0
fi

REAL_PATH=$(readlink -f "$CACHE_PATH")
echo "restore-wallpaper: Memulihkan wallpaper -> $REAL_PATH"

# 1. Restore wallpaper with awww / hyprpaper / swaybg
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
elif command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$CACHE_PATH" -m fill >/dev/null 2>&1 &
fi

# 2. Restore Pywal Colors
if command -v wal > /dev/null 2>&1; then
    wal -R -q --noswallow 2>/dev/null || wal -i "$REAL_PATH" -q 2>/dev/null
    if [ -f "$HOME/.cache/wal/sequences" ]; then
        for pts in /dev/pts/[0-9]*; do
            cat "$HOME/.cache/wal/sequences" > "$pts" 2>/dev/null || true
        done
    fi
    if [ -f "$HOME/.cache/wal/colors.sh" ] && command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        source "$HOME/.cache/wal/colors.sh"
        hyprctl keyword general:col.active_border "$color11 $color14 45deg" 2>/dev/null || true
        hyprctl keyword general:col.inactive_border "$color1" 2>/dev/null || true
    fi
fi
