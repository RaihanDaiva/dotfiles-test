# Dotfiles Wayland (Niri & Hyprland + Quickshell) - Context & Instructions for Gemini

## 1. Ringkasan Proyek
- **Deskripsi:** Konfigurasi dotfiles Wayland modular untuk dua window manager / compositor (**Niri** dan **Hyprland**) yang terintegrasi dengan custom desktop shell berbasis **Quickshell** (`han-dots`) serta theming dinamis berbasis Pywal.
- **Tech Stack:**
  - **Compositors & Window Managers:** Niri (modular KDL), Hyprland (modular conf).
  - **Shell / UI Framework:** Quickshell (QML / QtQuick 6, Wayland LayerShell).
  - **Theming & Color Palette:** Pywal (`~/.cache/wal/colors.json`) dengan fallback Catppuccin.
  - **Scripting:** Bash (helper scripts, pipewire monitor, wallpaper engine).

---

## 2. Struktur Repositori
Berikut letak direktori penting agar model tidak salah membaca atau menaruh file:
- `niri/`: Konfigurasi compositor Niri dalam format modular KDL (`config.d/`).
  - `10-input-and-cursor.kdl` (input/cursor), `20-layout-and-overview.kdl` (layout/gaps), `70-binds.kdl` (keybindings), `90-user-extra.kdl` (user overrides & focus ring dynamic patch).
- `test-hypr/`: Konfigurasi compositor Hyprland (`hyprland.conf`, `autostart.conf`, `keybinds.conf`, `windowrule.conf`, `hyprcolors.conf`, dll.).
- `quickshell/han-dots/`: **Shell aktif pengguna (Tracked)**. Entry point: `shell.qml`.
  - `components/`: Komponen jendela dan popup (`Dock.qml`, `popups/appLauncherPopup/`, `popups/wallpaperPopup/`, `popups/powerPopup/`, dll.).
  - `widgets/`: Widget antarmuka status bar (`widgets/bar/Workspace.qml`, clock, battery, tray, dll.).
  - `services/`: Service data & IPC state (`SettingsStore.qml`, `HyprlandData.qml`, dll.).
  - `theme/`: Sinkronisasi tema dan warna (`Theme.qml`, `PywalService.qml`).
  - `scripts/`: Skrip otomasi wallpaper dan monitor event (`apply_wallpaper.sh`, `restore-wallpaper.sh`, dll.).
- `quickshell/inir/` & `quickshell/ii/`: Upstream iNiR shell (**Gitignored**). **JANGAN PERNAH** memodifikasi atau membuat file di direktori ini.

---

## 3. Standar & Konvensi Kode
- **Gaya Penulisan QML:**
  - PascalCase untuk penamaan file komponen (misal `Workspace.qml`, `AppLauncherPopup.qml`).
  - camelCase untuk `id`, fungsi, sinyal, dan properti.
  - **Centralized Logic / Single Source of Truth:** Untuk komponen dengan varian style (seperti `*StyleMacos.qml` dan `*StyleOriginal.qml`), letakkan seluruh event handling / navigasi keyboard di file induk (`*Popup.qml`) dan delegasikan ke child style via handler function.
- **Konfigurasi Compositor:**
  - Niri: Pastikan format sintaks KDL valid, simpan override dinamis pengguna di `90-user-extra.kdl`.
  - Hyprland: Gunakan format sintaks `.conf` modular yang dipanggil dari `hyprland.conf`.

---

## 4. Alur & Perintah Penting (Allowed Commands)
Daftar perintah shell yang diizinkan untuk validasi dan penataan kode:
- **Validasi konfigurasi Niri:**
  ```bash
  niri validate
  ```
- **Formatting dan Validasi Quickshell (QML):**
  ```bash
  qmlformat -i <path/ke/file.qml>
  ```
  *(Opsional: `qmllint <path/ke/file.qml>` jika diperlukan untuk analisis sintaks QML)*
- **Validasi dan Reload Hyprland:**
  ```bash
  hyprctl reload
  ```

---

## 5. Batasan & Aturan Khusus (Do's and Don'ts)
- **DO:**
  - **Langsung Eksekusi Perbaikan:** Ketika inti masalah sudah dipahami, langsung lakukan pengeditan kode secara presisi tanpa berputar-putar.
  - **Konfirmasi Perintah Tambahan:** Jika perlu menjalankan command shell selain 3 perintah validasi di atas, **tanyakan dan mintalah izin kepada user terlebih dahulu** sebelum mengeksekusinya.
  - Pastikan setiap perubahan QML diformat menggunakan `qmlformat -i`.
- **DON'T:**
  - **Jangan menjalankan banyak command shell yang tidak jelas/berulang** (seperti looping curl, web-scraping script, atau python helper yang tidak diminta).
  - **Jangan membaca seluruh dokumentasi atau file yang tidak relevan** jika akar permasalahan sudah jelas.
  - **JANGAN PERNAH me-restart atau me-kill proses `quickshell`** (`killall quickshell`, `pkill quickshell`, dll.). Quickshell me-reload secara otomatis saat file disimpan.
  - **Jangan mengubah file pada direktori gitignored** (`quickshell/inir/` dan `quickshell/ii/`). Selalu pastikan perubahan dilakukan pada `quickshell/han-dots/`.
