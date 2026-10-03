#!/usr/bin/env bash

# Query Soundcore R50i battery percentage via bluetoothctl / UPower
MAC="18:9C:2C:8B:6C:07"
MAC_UNDERSCORE="18_9C_2C_8B_6C_07"

# 1. Check via bluetoothctl
if command -v bluetoothctl >/dev/null 2>&1; then
    info=$(bluetoothctl info "$MAC" 2>/dev/null)
    if echo "$info" | grep -q "Connected: yes"; then
        bat=$(echo "$info" | grep -i "Battery Percentage:" | sed -n 's/.*(\([0-9]\+\)).*/\1/p')
        if [[ "$bat" =~ ^([0-9]|[1-9][0-9]|100)$ ]]; then
            printf '%s%%\n' "$bat"
            exit 0
        fi
    else
        printf 'N/A\n'
        exit 0
    fi
fi

# 2. Fallback via UPower
if command -v upower >/dev/null 2>&1; then
    up_dev="/org/freedesktop/UPower/devices/headset_dev_${MAC_UNDERSCORE}"
    if upower -e 2>/dev/null | grep -q "$up_dev"; then
        bat=$(upower -i "$up_dev" 2>/dev/null | awk '/percentage:/ {print $2}' | tr -d '%')
        if [[ "$bat" =~ ^([0-9]|[1-9][0-9]|100)$ ]]; then
            printf '%s%%\n' "$bat"
            exit 0
        fi
    fi
fi

printf 'N/A\n'
