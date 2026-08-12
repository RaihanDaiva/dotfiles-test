#!/bin/bash

# 1. Primary Backlight (Internal screen)
PRIM_PCT=100
CUR_BR=$(brightnessctl -c backlight g 2>/dev/null || echo 0)
MAX_BR=$(brightnessctl -c backlight m 2>/dev/null || echo 0)
if [ "$MAX_BR" -gt 0 ]; then
    PRIM_PCT=$(( CUR_BR * 100 / MAX_BR ))
fi

# 2. Secondary Display (External monitor via ddcutil or extra backlight)
SEC_PCT=""
SEC_TYPE=""

# Check extra backlight devices first
EXTRA_BL=$(brightnessctl -c backlight -m 2>/dev/null | awk -F',' 'NR>1 {print $1}')
if [ -n "$EXTRA_BL" ]; then
    CUR_2=$(brightnessctl -d "$EXTRA_BL" g 2>/dev/null || echo 0)
    MAX_2=$(brightnessctl -d "$EXTRA_BL" m 2>/dev/null || echo 0)
    if [ "$MAX_2" -gt 0 ]; then
        SEC_PCT=$(( CUR_2 * 100 / MAX_2 ))
        SEC_TYPE="brightnessctl:$EXTRA_BL"
    fi
fi

# If no extra backlight device found, check ddcutil for DDC/CI external monitors
if [ -z "$SEC_PCT" ]; then
    DDC_OUT=$(ddcutil getvcp 10 --brief 2>/dev/null)
    if echo "$DDC_OUT" | grep -qE "^VCP 10 C"; then
        VAL=$(echo "$DDC_OUT" | awk '{print $4}')
        # Ensure VAL is a valid non-negative integer <= 100
        if [ -n "$VAL" ] && [ "$VAL" -eq "$VAL" ] 2>/dev/null && [ "$VAL" -ge 0 ] && [ "$VAL" -le 100 ]; then
            SEC_PCT="$VAL"
            SEC_TYPE="ddcutil:1"
        fi
    fi
fi

if [ -n "$SEC_PCT" ]; then
    echo "2"
    echo "Screen Brightness (first)"
    echo "$PRIM_PCT"
    echo "backlight"
    echo "Screen Brightness (second)"
    echo "$SEC_PCT"
    echo "$SEC_TYPE"
else
    echo "1"
    echo "Screen Brightness"
    echo "$PRIM_PCT"
    echo "backlight"
fi
