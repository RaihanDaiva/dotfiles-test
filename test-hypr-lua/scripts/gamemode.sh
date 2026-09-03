#!/bin/bash

# Cek status animasi saat ini (1 = On, 0 = Off)
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

if [ "$HYPRGAMEMODE" = 1 ] ; then
    # Matikan wallpaper
    killall hyprpaper &

    # --- AKTIFKAN MODE GAMING (Matikan Efek) ---
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:rounding 0"

    notify-send -u low "Game Mode" "ON (Effects Disabled)"
    exit
else
    # Nyalakan kembali wallpaper
    hyprpaper &
    # --- MATIKAN MODE GAMING (Nyalakan Efek) ---
    # Sesuaikan 'decoration:rounding 10' dengan settingan asli Anda
    hyprctl --batch "\
        keyword animations:enabled 1;\
        keyword decoration:blur:enabled 1;\
        keyword decoration:shadow:enabled 1;\
        keyword decoration:rounding 10"

    notify-send -u low "Game Mode" "OFF (Effects Enabled)"
    exit
fi