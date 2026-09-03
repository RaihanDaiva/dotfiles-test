#!/bin/bash

# Cek Rofi
if ! command -v rofi &> /dev/null; then
    notify-send "Error" "Rofi tidak terinstall"
    exit 1
fi

# Jalankan Rofi mode drun (Application Launcher)
# -show drun  : Mode aplikasi
# -p          : Ikon prompt (Kaca pembesar)
# -theme      : Mengarah ke file CSS yang baru kita buat

rofi -show drun \
    -theme ~/.config/rofi/launcher.rasi