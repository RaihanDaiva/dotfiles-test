#!/usr/bin/env bash
# QuickShell Han-Dots Screenshot Trigger

# Give popup time to fade out and compositor to settle
sleep 0.25

# 1. Check if running under Niri
if [ -n "$NIRI_SOCKET" ] || [[ "${XDG_CURRENT_DESKTOP,,}" == *"niri"* ]]; then
    niri msg action screenshot
# 2. Check if running under Hyprland
elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] || [[ "${XDG_CURRENT_DESKTOP,,}" == *"hyprland"* ]]; then
    if command -v hyprshot >/dev/null 2>&1; then
        hyprshot -m region
    else
        TARGET_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
        mkdir -p "$TARGET_DIR"
        FILE="$TARGET_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
        grim -g "$(slurp)" "$FILE"
        if [ -f "$FILE" ]; then
            wl-copy < "$FILE"
            notify-send "Screenshot Captured" "Saved to $FILE and copied to clipboard" -i "$FILE" -a "QuickShell"
        fi
    fi
# 3. Generic Wayland fallback
else
    if command -v grim >/dev/null 2>&1 && command -v slurp >/dev/null 2>&1; then
        TARGET_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
        mkdir -p "$TARGET_DIR"
        FILE="$TARGET_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
        grim -g "$(slurp)" "$FILE"
        if [ -f "$FILE" ]; then
            wl-copy < "$FILE"
            notify-send "Screenshot Captured" "Saved to $FILE and copied to clipboard" -i "$FILE" -a "QuickShell"
        fi
    fi
fi
