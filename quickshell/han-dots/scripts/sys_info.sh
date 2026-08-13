#!/bin/bash

# 1. RAM Usage Text
free -h | awk '/Mem:/ {print $3}'

# 2. CPU Temperature Text
TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
TEMP_VAL=$(( TEMP_RAW / 1000 ))
echo "${TEMP_VAL}°C"

# 3. Battery Capacity (%)
cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo "100"

# 4. Battery Status (Charging / Discharging / Full)
cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo "Discharging"

# 5. Wi-Fi Signal Strength (0-100)
WIFI_SIG=$(nmcli -t -f active,signal dev wifi 2>/dev/null | awk -F: '/^yes/ {print $2}' | head -n1)
if [ -n "$WIFI_SIG" ]; then
    echo "$WIFI_SIG"
else
    echo "0"
fi

# 6. Bluetooth Status (on / off)
if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo "on"
else
    echo "off"
fi

# 7. CPU Load (%)
LC_ALL=C top -bn1 2>/dev/null | awk '/Cpu/ {print int($2+$4)}' || echo "15"

# 8. CPU Temp Numerical Value
echo "$TEMP_VAL"

# 9. RAM Usage (%)
free | awk '/Mem:/ {print int($3/$2 * 100)}'

# 10. RAM Details (e.g. 10Gi / 15Gi)
free -h | awk '/Mem:/ {print $3 " / " $2}'

# 11. Disk Usage (%)
df -h / | awk 'NR==2 {print int($5)}'

# 12. Disk Details (e.g. 105G / 250G)
df -h / | awk 'NR==2 {print $3 " / " $2}'

# 13 & 14. GPU Load (%) and GPU Temp (°C)
GPU_INFO=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
GPU_LOAD=0
GPU_TEMP=0

if [ -n "$GPU_INFO" ]; then
    GPU_LOAD=$(echo "$GPU_INFO" | awk -F',' '{print int($1)}')
    GPU_TEMP=$(echo "$GPU_INFO" | awk -F',' '{print int($2)}')
fi

# Multi-GPU & Sysfs fallback for Optimus/Hybrid graphics
if [ "$GPU_LOAD" -eq 0 ]; then
    SYS_BUSY=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || echo 0)
    if [ "$SYS_BUSY" -gt 0 ]; then
        GPU_LOAD=$SYS_BUSY
    fi
fi

# Fallback CPU temp if GPU temp unavailable
if [ "$GPU_TEMP" -eq 0 ]; then
    GPU_TEMP=$TEMP_VAL
fi

echo "$GPU_LOAD"
echo "$GPU_TEMP"

# 15 & 16. Volume Percent (%) and Mute Status
VOL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo "Volume: 0.50")
VOL_VAL=$(echo "$VOL_RAW" | awk '{print int($2 * 100)}')
echo "$VOL_VAL"

if echo "$VOL_RAW" | grep -q "MUTED"; then
    echo "muted"
else
    echo "unmuted"
fi

# 17. Brightness %
CUR_BR=$(brightnessctl g 2>/dev/null || echo 100)
MAX_BR=$(brightnessctl m 2>/dev/null || echo 100)
if [ "$MAX_BR" -gt 0 ]; then
    BR_PCT=$(( CUR_BR * 100 / MAX_BR ))
else
    BR_PCT=100
fi
echo "$BR_PCT"

# 18. User Display Name
USER_NAME=$(getent passwd $USER 2>/dev/null | cut -d: -f5 | cut -d',' -f1)
if [ -z "$USER_NAME" ]; then
    USER_NAME=$USER
fi
echo "$USER_NAME"
