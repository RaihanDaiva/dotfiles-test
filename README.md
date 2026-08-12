# ❄️ Dotfiles Test: Hyprland & Quickshell Ricing Setup

A modular, modern Linux desktop environment configuration built for **Hyprland** and **Quickshell** (QtQuick/QML-based Wayland shell). 

This repository contains an isolated testing environment (`test-hypr`) for experimentation alongside a custom status bar built from scratch with Quickshell.

---

## 🚀 Features

### 🏛️ Status Bar & Widgets (Quickshell)
- **Mathematical Screen Center Alignment:** Independent component anchoring ensures the center island (Clock) stays in the exact mathematical center of the screen regardless of left/right island sizes.
- **Modular 3-Widget Right Island Architecture:**
  - **SystemStats (`SystemStats.qml`):** Dedicated RAM usage & CPU temperature monitor pill triggering `SysStatsPopup`.
  - **ControlCenter (`ControlCenter.qml`):** Quick settings control pill (Brightness %, Volume %, Bluetooth, Wi-Fi, Battery %) triggering `QuickSettingsPopup` & `OsdPopup`.
  - **Power (`Power.qml`):** Standalone circular Power button (`󰐥`) triggering `PowerPopup`.
- **Sliding Workspace Pill:** Smooth `OutCubic` sliding animation (`Behavior on x`) when switching active workspaces, with accurate coordinate mapping via `mapToItem`.
- **Hybrid Workspace Model:** Displays base static workspaces (`I` to `V`) and dynamically appends extra workspaces (`VI`, `VII`, etc.) when active or occupied.
- **Logical Visual Hierarchy:**
  - **Active Workspace:** High-contrast dark text (`Theme.bgDark`) over the bright accent pill.
  - **Occupied Workspace:** Bright text (`Theme.textMain`) indicating running applications.
  - **Empty Workspace:** Muted 35% opacity text (`Theme.textMain` 0.35 alpha) to reduce visual clutter.
- **Modular Popup Architecture (`BasePopup.qml` & `components/popups/`):**
  - Reusable `PanelWindow` shell encapsulated in `widgets/BasePopup.qml`.
  - Built-in Wayland LayerShell setup (`WlrLayershell.namespace: "quickshell:popup"`), Hyprland glassmorphism blur, translucent Pywal background (`0.5` alpha), and dual slide/fade enter-exit animations.
  - **Dynamic Wayland Keyboard Focus:** `requiresKeyboardFocus` property switching `WlrLayershell.keyboardFocus` dynamically to `WlrKeyboardFocus.OnDemand` whenever text input is active, allowing seamless typing in popups without stealing desktop focus otherwise.
  - **Smart Clamped Positioning (`updatePosition()`):** Auto-centers popup under target widget, and dynamically clamps left/right edges flush with the status bar boundaries if overflowing.
  - Centralized popup repository under `components/popups/` for clean imports and maintainability.
- **Unified Status Bar Pill Hover System:**
  - Standardized uniform pill hover rectangle (`height: 26px`, `radius: 8px`, translucent Pywal `0.15` background with `0.3` accent border) across all primary status bar widgets (`Clock.qml`, `MediaPlayer.qml`, `SystemStats.qml`, `ControlCenterWidget.qml`, `PowerWidget.qml`).
- **Power Button & Vertical Pill Power Menu (`PowerPopup.qml`):**
  - Dedicated circular Power button (`󰐥`) positioned cleanly as its own standalone pill widget on the right island.
  - **Vertical Pill Dropdown Menu (Opsi B):** Profile header with live uptime display + 5 rounded action pills for **Shutdown** (`systemctl poweroff`), **Reboot** (`systemctl reboot`), **Suspend** (`systemctl suspend`), **Lock Screen** (`hyprlock`), and **Log Out** (`hyprctl dispatch exit`).
  - Distinct color-coded hover highlights for each action pill (Rose `#f38ba8` for Shutdown, Accent for Reboot, Teal `#89dceb` for Suspend, Gold `#f9e2af` for Lock, Orange `#fab387` for Logout).
- **Native Desktop Notification Daemon & Overlay (`NotificationPopup.qml` & `NotificationServer`):**
  - Built directly on Quickshell's native DBus `NotificationServer` daemon (`Quickshell.Services.Notifications`).
  - **Extends `PanelWindow` Overlay:** Top-Right alignment flush under status bar with Hyprland glassmorphism blur and Pywal theme integration.
  - **Reference-Matched Layout:** Displays a left circular app icon avatar with badge indicator, bold summary title, multi-line wrapped body message, and dismiss button (`󰅖`).
  - **Smart Hover Pausing:** Pauses 5-second auto-dismiss timer on mouse hover and resumes on leave.
- **Real-Time On-Screen Display (OSD) Overlay (`OsdPopup.qml`):**
  - Floating bottom-centered glassmorphism overlay card (`WlrLayer.Overlay`) rendering real-time volume and brightness indicators with smooth `OutCubic` entrance/exit animations.
  - **0ms Real-Time Event Listener (`sys_event_monitor.sh`):** Streams PipeWire audio events via `pactl subscribe` and Linux kernel backlight events via `udevadm monitor --subsystem-match=backlight` for instant OSD updates when adjusting volume or brightness via keyboard **Fn** shortcuts.
  - **Auto-Hide:** Automatically fades out after 1.8 seconds of inactivity.
- **System Performance Dashboard (`SysStatsPopup.qml`):**
  - **5-Circle Symmetrical Ring Gauge Layout:**
    - **CPU Load (`󰻠`):** Real-time processor utilization ring gauge with dynamic status badges (*Normal / High / Critical*).
    - **GPU Load (`󰢮`):** Real-time GPU utilization ring gauge powered by `nvidia-smi` and Linux DRM sysfs (`gpu_busy_percent`) fallback.
    - **CPU Temp (`󰔏`):** Thermal status ring gauge for CPU (*Good / Warm / Hot*).
    - **GPU Temp (`󰔏`):** Thermal status ring gauge for GPU (*Good / Warm / Hot*).
    - **Memory (`󰍛`):** Centered RAM utilization ring gauge with exact capacity metrics (*e.g. 10Gi / 15Gi*).
  - **Storage Disk Usage Bar:** Full-width progress bar tracking root `/` partition storage space (*e.g. 105G / 250G*).
  - **Styling Polish:** Scaled gauge icons (`24px`), swapped icon/value colors (`Theme.textMain` for icons, dynamic status colors for numbers), and clear text labels.
- **Windows 11 Style Control Center Hub (`QuickSettingsPopup.qml`):**
  - **3-Page Horizontal Sliding Drill-Down Navigation:**
    - **Page 0 (Main Page):** Fixed User Profile + Battery status header, Wi-Fi & Bluetooth control pills, Dynamic Multi-Monitor Brightness slider(s), and Volume Overamplification slider (0–150%).
    - **Page 1 (Detail List Page):** Real-time scanned Wi-Fi networks (SSID, signal %, connection status, connect action) or paired Bluetooth devices (clean name, status, connect action) with master toggle switch and scan button.
    - **Page 2 (Wi-Fi Password Input Page):** Dedicated password input page sliding in when connecting to unremembered Wi-Fi networks. Features target SSID display, show/hide password toggle (`󰈈`/`󰈂`), status feedback (*Connecting… / Connected! / Connection failed*), Enter key acceptance, and automated `nmcli` connection process.
  - **Volume Overamplification (0%–150% Boost):**
    - Seamlessly supports volume boost up to **150%** via `wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ <pct>%`.
    - Progress bar fill scales proportionally up to 150% with coral over-boost highlights (`#f38ba8`) and boosted icon indicators (`󱄡`).
  - **Dynamic Multi-Monitor Screen Brightness Detection:**
    - Automatically detects external monitors via `brightness_info.sh` supporting internal panels (`brightnessctl`) and external displays via DDC/CI (`ddcutil`) or secondary GPU backlights.
    - **Single Monitor:** Displays single slider titled `"Screen Brightness"`.
    - **Dual / Multi-Monitor:** Dynamically appends secondary slider titled `"Screen Brightness (first)"` and `"Screen Brightness (second)"`.
    - **Robust 0% Brightness Parsing:** Uses `isNaN()` check to ensure 0% brightness is parsed accurately without jumping to 100%.
  - **Reliable Bluetooth Power Toggle:** Split subcommand arguments (`["bluetoothctl", "power", "off"]`) for smooth Bluetooth power toggling.
  - **Optically Centered Circle Icons:** `anchors.centerIn` with `anchors.horizontalCenterOffset: -1` in `ControlPill.qml` for optical alignment inside circular icon buttons.
  - **Bluetooth & Wi-Fi List Delegate Parity:** Identical text font sizing and weights across Wi-Fi and Bluetooth list delegates (Icon: 16px, Name: 14px bold, Status/Action: 12px bold).
- **Dynamic MPRIS Media Player Widget (`MediaPlayer.qml` & `MediaPopup.qml`):**
  - Real-time media control powered natively by `Quickshell.Services.Mpris` (Spotify, Firefox/YouTube, Amberol, MPV, VLC, etc.) with **Smart-Select Active Player Filtering** prioritizing actively playing media over idle browser tabs.
  - **Bar Layout:** Dual vertical `MarqueeText` instances in a `ColumnLayout` for Title (11px bold) and Artist (9px) preventing text overlaps.
  - **Interactive Hover Detail Card (`MediaPopup.qml`):** Reordered vertical layout: $1:1$ Square Album Cover Art ($278\times278\text{px}$) $\rightarrow$ Track Title & Artist $\rightarrow$ Interactive Seek Progress Slider & Position Ticker $\rightarrow$ Optically Centered Playback Controls.
- **Status Bar Metrics:**
  - **Screen Brightness Indicator:** Live brightness icon (`󰃠`) and percentage (`100%`) positioned directly to the left of Volume on the status bar pill (`controlPill`).
  - **PipeWire Volume %:** Real-time volume & mute status (`󰕾` / `󰝟`).
  - **Robust Bluetooth & Wi-Fi Metrics:** Line-guaranteed output parsing in `sys_info.sh` ensuring Bluetooth status remains accurate (`󰂯`) even when Wi-Fi is disabled.
  - **Battery State:** Smart battery status (`󰂄` charging, `󰁹` full) with automatic red warning color (`#f38ba8`) when battery drops below 20%.

---

## 📂 Repository Structure

```text
dotfiles-test/
├── test-hypr/                      # Isolated Hyprland configuration
│   ├── hyprland.conf               # Core Hyprland configuration (sourcing test-hypr files)
│   ├── autostart.conf              # Autostart applications & background daemons
│   ├── keybinds.conf               # Rebound shortcuts ($mainMod = ALT)
│   ├── input.conf                  # Keyboard layout & touchpad settings
│   ├── layerrule.conf              # Blur & window rules (ignore_alpha 0.5 for quickshell & quickshell:popup)
│   ├── monitors.conf               # Display monitor setup
│   └── scripts/                    # Wallpaper & utility scripts (set-wallpaper.sh, etc.)
│
└── quickshell/                     # Quickshell UI configuration
    ├── shell.qml                   # Main entry point (Scope wrapper loading PywalService, Bar & NotificationServer)
    ├── components/
    │   ├── Bar.qml                 # Top Status Bar layout
    │   └── popups/                 # 🪟 CENTRALIZED POPUP REPOSITORY
    │       ├── CalendarPopup.qml   # Interactive monthly calendar, live clock & uptime popup
    │       ├── MediaPopup.qml      # Floating detail card with 1:1 cover art, seek bar & playback controls
    │       ├── SysStatsPopup.qml   # 5-Circle Performance Dashboard popup (CPU/GPU Load & Temp, Mem, Storage)
    │       ├── QuickSettingsPopup.qml # Windows 11 style 3-tier sliding Control Center popup
    │       ├── OsdPopup.qml        # Real-time OSD overlay card for Volume & Brightness
    │       ├── NotificationPopup.qml # Native desktop notification popup extending BasePopup
    │       └── PowerPopup.qml      # Power menu popup dropdown extending BasePopup
    ├── theme/
    │   ├── Theme.qml               # Clean Singleton storing pure font & color properties
    │   └── PywalService.qml        # Background service syncing Pywal colors to Theme.qml
    ├── widgets/
    │   ├── BasePopup.qml           # Reusable PanelWindow popup shell with dynamic Wayland keyboard focus & blur
    │   ├── ControlPill.qml         # Reusable control button pill with optical center offset
    │   └── bar/
    │       ├── Workspace.qml       # Hybrid workspace switcher with sliding animation
    │       ├── Clock.qml           # Real-time clock & date widget with pill hover trigger
    │       ├── MediaPlayer.qml     # Dynamic MPRIS media player entry point with dual MarqueeText column
    │       ├── mediaPlayerWidget/  # Sub-components for media player
    │       │   ├── MarqueeText.qml # Reusable endless continuous marquee text
    │       │   └── CavaVisualizer.qml # 24-bar PipeWire Cava audio visualizer
    │       ├── SystemStats.qml     # RAM & CPU Temp performance monitor widget
    │       ├── ControlCenter.qml   # Quick settings control pill widget (Brightness/Vol/BT/WiFi/Bat)
    │       └── Power.qml           # Standalone Power button widget
    └── scripts/
        ├── sys_info.sh             # Executable bash helper script for system metrics, GPU stats & volume
        ├── sys_event_monitor.sh    # Real-time event streamer for PipeWire audio & kernel backlight
        ├── brightness_info.sh      # Helper script detecting internal and DDC/CI external display brightness
        ├── wifi_list.sh            # Helper script parsing unique signal-sorted Wi-Fi networks via nmcli
        └── bt_list.sh              # Helper script parsing Bluetooth device status and clean names via pipe delimiter
```

---

## 🛠️ Installation & Setup

### Prerequisites
Ensure the following packages are installed on your system (e.g. Arch Linux / CachyOS):
- `hyprland`
- `quickshell`
- `libnotify` (`notify-send`)
- `cava` (for real-time PipeWire audio visualizer)
- `pywal` (`wal`)
- `bluez` / `bluez-utils` (`bluetoothctl`)
- `ddcutil` (optional for external monitor DDC/CI brightness control)
- `qt6-declarative` / `qt6-5compat` / `qt6-shadertools` (for QML runtime, `QtQuick.Effects`, & `qmlformat`)
- `procps-ng` (`free`), `networkmanager` (`nmcli`), `bash`, `pipewire` (`wpctl`), `brightnessctl`, `nvidia-utils` (optional for NVIDIA GPU stats)

### 1. Symlink Configuration (Recommended)
Link the repository directories to `~/.config/` so any edits sync automatically:

```bash
# Clone the repository
git clone https://github.com/RaihanDaiva/dotfiles-test.git ~/dotfiles-test

# Backup existing configs if necessary, then create symlinks
ln -sf ~/dotfiles-test/test-hypr ~/.config/test-hypr
ln -sf ~/dotfiles-test/quickshell ~/.config/quickshell

# Make helper scripts executable
chmod +x ~/dotfiles-test/quickshell/scripts/*.sh
```

### 2. Testing in Nested Hyprland
Launch the isolated testing environment in a window:

```bash
Hyprland -c ~/.config/test-hypr/hyprland.conf
```

### 3. Launching Quickshell
Inside your Hyprland testing session, launch Quickshell from a terminal:

```bash
quickshell
```

---

## 🎨 Keyboard Shortcuts (Testing Session)

| Shortcut | Action |
| :--- | :--- |
| `Alt + Return` | Open Terminal (Kitty) |
| `Alt + Q` | Close Active Window |
| `Alt + M` | Exit Hyprland Session |
| `Alt + 1` .. `Alt + 5` | Switch Workspaces |

---

## 📝 Maintenance & Contribution
This `README.md` is updated regularly alongside repository commits to reflect current features, directory structures, and code architecture changes.
