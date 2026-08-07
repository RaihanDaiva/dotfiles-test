#!/bin/bash
# restore-wallpaper.sh
# Dipanggil saat boot via exec-once untuk me-restore wallpaper terakhir
# beserta semua efek (pywal colors, border Hyprland, dsb.)

CACHE_PATH="$HOME/.cache/current_wallpaper.jpg"

# --- Tunggu hyprpaper benar-benar siap ---
sleep 1

# --- Cek apakah file/symlink wallpaper cache ada ---
if [ ! -e "$CACHE_PATH" ]; then
    echo "restore-wallpaper: $CACHE_PATH tidak ditemukan, skip."
    exit 0
fi

# Resolve path asli jika symlink (untuk pywal)
REAL_PATH=$(readlink -f "$CACHE_PATH")

echo "restore-wallpaper: Memulihkan wallpaper -> $REAL_PATH"

# --- Pastikan hyprpaper sudah jalan ---
for i in $(seq 1 10); do
    if pgrep -x "hyprpaper" > /dev/null; then
        break
    fi
    echo "restore-wallpaper: Menunggu hyprpaper... ($i/10)"
    sleep 0.5
done

if ! pgrep -x "hyprpaper" > /dev/null; then
    echo "restore-wallpaper: hyprpaper tidak kunjung jalan, abort."
    exit 1
fi

# --- Terapkan wallpaper via hyprctl ---
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$CACHE_PATH"
hyprctl hyprpaper wallpaper ",$CACHE_PATH"

echo "restore-wallpaper: Wallpaper berhasil diterapkan!"

# --- Restore warna Pywal (jika tersedia) ---
if command -v wal > /dev/null 2>&1; then
    echo "restore-wallpaper: Mengembalikan warna Pywal..."
    # -R = restore dari cache terakhir, tidak perlu generate ulang
    wal -R -q --noswallow 2>/dev/null || wal -i "$REAL_PATH" -n -q 2>/dev/null

    # Load variabel warna untuk border Hyprland
    if [ -f "$HOME/.cache/wal/colors.sh" ]; then
        source "$HOME/.cache/wal/colors.sh"
        hyprctl keyword general:col.active_border "$color11 $color14 45deg"
        hyprctl keyword general:col.inactive_border "$color1"
        echo "restore-wallpaper: Warna border Hyprland berhasil diupdate!"
    fi
fi
