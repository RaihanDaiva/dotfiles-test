#!/bin/bash
# 🎨 KITTY THEME SWITCHER
# Usage: switch_kitty_theme.sh dark | light
#
# Mengganti tema Kitty terminal secara langsung tanpa restart:
#   1. Update current-theme.conf (copy ke dark-theme.conf / light-theme.conf)
#   2. Kirim perintah set-colors ke semua Kitty window aktif via remote control

MODE="${1:-dark}"
KITTY_DIR="$HOME/.config/kitty"
DARK_THEME="$KITTY_DIR/dark-theme.conf"
LIGHT_THEME="$KITTY_DIR/light-theme.conf"
CURRENT_THEME="$KITTY_DIR/current-theme.conf"

# Pilih file theme yang sesuai
if [ "$MODE" = "light" ]; then
    TARGET="$LIGHT_THEME"
else
    TARGET="$DARK_THEME"
fi

# Fallback: jika file tema target tidak ada, pakai yang lain
if [ ! -f "$TARGET" ]; then
    echo "Kitty theme file not found: $TARGET"
    exit 0
fi

# 1. Update current-theme.conf (copy agar window baru pakai tema yang benar)
cp "$TARGET" "$CURRENT_THEME"

# 2. Kirim set-colors ke semua Kitty window aktif via remote control (real-time tanpa restart)
# --all        = terapkan ke SEMUA window yang sedang berjalan
# --configured = terapkan juga sebagai warna default untuk window baru
if command -v kitten >/dev/null 2>&1; then
    kitten @ set-colors --all --configured "$TARGET" 2>/dev/null || true
fi
