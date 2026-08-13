#!/bin/bash

# Real-time Volume & Brightness Event Streamer for Quickshell

get_vol() {
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    pct=$(echo "$vol" | awk '{print int($2 * 100)}')
    muted="unmuted"
    echo "$vol" | grep -q "MUTED" && muted="muted"
    echo "VOL:$pct:$muted"
}

get_bright() {
    cur=$(brightnessctl -c backlight g 2>/dev/null || echo 0)
    max=$(brightnessctl -c backlight m 2>/dev/null || echo 1)
    if [ "$max" -gt 0 ]; then
        pct=$(( cur * 100 / max ))
    else
        pct=100
    fi
    echo "BRIGHT:$pct"
}

# Run pactl subscribe for instant volume events
(
    pactl subscribe 2>/dev/null | grep --line-buffered "change' on sink" | while read -r line; do
        get_vol
    done
) &
PID1=$!

# Run udevadm monitor for instant backlight events
(
    udevadm monitor --subsystem-match=backlight 2>/dev/null | grep --line-buffered "change" | while read -r line; do
        get_bright
    done
) &
PID2=$!

trap "kill $PID1 $PID2 2>/dev/null" EXIT

# Initial state sync
get_vol
get_bright

wait
