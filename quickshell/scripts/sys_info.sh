#!/bin/bash

# 1. RAM Usage
free -h | awk '/Mem:/ {print $3}'

# 2. CPU Temperature
echo "$(( $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0) / 1000 ))°C"

# 3. Battery Capacity (%)
cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo "100"

# 4. Battery Status (Charging / Discharging / Full)
cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo "Discharging"

# 5. Wi-Fi Signal Strength (0-100)
nmcli -t -f active,signal dev wifi 2>/dev/null | awk -F: '/^yes/ {print $2}'

# 6. Bluetooth Status (on / off)
if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo "on"
else
    echo "off"
fi
