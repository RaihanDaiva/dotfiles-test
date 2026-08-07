#!/bin/bash

# Pastikan rofi terinstall
if ! command -v rofi &> /dev/null; then
    echo "Rofi tidak ditemukan. Install rofi-wayland dulu."
    exit 1
fi

# Daftar Keybind
# Saya tambahkan tag <b>...</b> untuk judul kategori agar tebal
# Format: Icon  Key  |  Deskripsi
echo -e "<b>APPLICATION</b>
   Super + Enter    |  Terminal (Kitty)
   Super + B        |  Browser (Zen Browser)
   Super + E        |  File Manager
󰨞   Super + C        |  Visual Studio Code
   Super + D        |  Discord

<b>TOOLS</b>
   Super + A        |  App Launcher (Rofi)
󰐥   Super + P        |  Power Menu (wlogout)
󰌾   Super + L        |  Lockscreen (hyprlock)
󰅇   Super + V        |  Clipboard
󰂚   Super + N        |  Notification Center
󰊖   Super + G        |  Toggle Game Mode
   Super + J        |  Toggle Waybar
󰸉   Super + R        |  Random Wallpaper
󰸉   Super + W        |  Set Wallpaper
   PrntScr          |  Screenshot Full
   Win+Shift+S      |  Screenshot Area

<b>WINDOW MANAGEMENT</b>
   Super + 1-5      |  Change Workspace
   Super + R Mouse  |  Resize Window
   Super + L Mouse  |  Move Window
   Super + Q        |  Close Window
   Super + F        |  Toggle Floating
   Super + ;        |  Shrink Window Left
   Super + '        |  Grow Window Right
" | \
rofi -dmenu \
    -markup-rows \
    -i \
    -p "  " \
    -theme ~/.config/rofi/cheatsheet.rasi