#!/bin/bash
# Hapus "set -e" agar script tidak mati jika user menekan ESC (Cancel)
# set -eu

# --- KONFIGURASI ---
WALL_DIR="$HOME/.config/wallpapers"

# Cek apakah Rofi sudah terinstall
if ! command -v rofi &> /dev/null; then
    echo "Error: Rofi tidak ditemukan. Silakan install 'rofi-wayland' terlebih dahulu."
    exit 1
fi

# 1. Cek Folder
if [ ! -d "$WALL_DIR" ]; then
    echo "Error: Folder $WALL_DIR tidak ada."
    exit 1
fi

# 2. Pastikan Hyprpaper Jalan
if ! pgrep -x "hyprpaper" > /dev/null; then
    echo "Hyprpaper mati. Menyalakan..."
    hyprpaper &
    sleep 1
fi

# 3. Pilih Wallpaper dengan Preview (Menggunakan Rofi)
# Kita melakukan loop file untuk memformat input agar dimengerti Rofi:
# Format: "NamaFile \0icon\x1f PathLengkap"
# -show-icons: Mengaktifkan mode gambar
# -theme-str: Mengatur tampilan jadi GRID (Kotak-kotak) biar seperti galeri
SELECTED_FILE=$(find "$WALL_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -printf "%f\n" | sort | while read -r file; do
    echo -en "$file\0icon\x1f$WALL_DIR/$file\n"
done | rofi -dmenu -i -p "  " -theme ~/.config/rofi/wallpaper-select.rasi)

# Jika user menekan ESC atau tidak memilih apa-apa
if [ -z "$SELECTED_FILE" ]; then
    echo "Tidak ada file yang dipilih."
    exit 0
fi

# Mendefinisikan jalur file asli dan file cache
FULL_PATH="$WALL_DIR/$SELECTED_FILE"
CACHE_PATH="$HOME/.cache/current_wallpaper.jpg"

echo "Memilih: $FULL_PATH"

# --- 4. EKSEKUSI HYPRPAPER ---

# Langkah A: Buat/Update shortcut 'current_wallpaper.jpg' TERLEBIH DAHULU
ln -sf "$FULL_PATH" "$CACHE_PATH"
# cp -f "$FULL_PATH" "$CACHE_PATH"

# Langkah B: Buang SEMUA gambar lama dari RAM agar tidak bocor dan hyprpaper sadar ada gambar baru
hyprctl hyprpaper unload all

# Langkah C: Muat (Preload) file cache yang sudah diupdate
hyprctl hyprpaper preload "$CACHE_PATH"

# Langkah D: Terapkan Wallpaper ke semua monitor (tanda koma di depan path)
hyprctl hyprpaper wallpaper ",$CACHE_PATH"

echo "Sukses mengirim perintah ke Hyprpaper!"


# --- 5. Update Pywal (Tema Terminal) ---
if command -v wal >/dev/null 2>&1; then
    echo "Mengupdate warna Pywal..."
    # -n berarti "Skip setting wallpaper" agar tidak conflict
    wal -i "$FULL_PATH" -n 
    
    # --- 6. UPDATE BORDER HYPRLAND ---
    # Load variabel warna pywal
    source "$HOME/.cache/wal/colors.sh"

    # Suntikkan warna ke Hyprland
    hyprctl keyword general:col.active_border "$color11 $color14 45deg"
    hyprctl keyword general:col.inactive_border "$color1"
    
    echo "Warna border Hyprland berhasil diupdate!"
fi

# --- 7. Reload Cava ---
if pgrep -x "cava" > /dev/null; then
    echo "Reloading Cava..."
    pkill -USR1 cava
fi

# --- 8. Reload Waybar ---
# Mematikan dan menyalakan ulang Waybar agar warnanya ikut berubah
pkill waybar && waybar &

# --- 9. Notifikasi (Opsional, butuh libnotify) ---
notify-send "Wallpaper Changed" "$SELECTED_FILE" -i "$FULL_PATH"

hyprctl reload