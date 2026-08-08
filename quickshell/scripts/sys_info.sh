#!/bin/bash

# 1. RAM Usage
free -h | awk '/Mem:/ {print $3}'

# 2. CPU Temperature
echo "$(( $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0) / 1000 ))°C"

# 3. Battery Capacity
cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo "100%"

# 4. Active Wi-Fi SSID
nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '/^yes/ {print $2}'
