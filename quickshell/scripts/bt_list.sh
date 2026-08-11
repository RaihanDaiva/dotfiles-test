#!/bin/bash
# bt_list.sh — Output daftar perangkat Bluetooth yang paired
# Format setiap baris: status|mac|name
# status = "connected" jika sedang terkoneksi, "paired" jika hanya paired

bluetoothctl devices 2>/dev/null | while read _ mac name; do
    if [ -z "$mac" ] || [ -z "$name" ]; then continue; fi
    connected=$(bluetoothctl info "$mac" 2>/dev/null | grep -c "Connected: yes")
    if [ "$connected" -gt 0 ]; then
        echo "connected|$mac|$name"
    else
        echo "paired|$mac|$name"
    fi
done | head -8
