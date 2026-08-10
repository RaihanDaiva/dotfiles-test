# ❄️ Dotfiles Test: Hyprland & Quickshell Ricing Setup

A modular, modern Linux desktop environment configuration built for **Hyprland** and **Quickshell** (QtQuick/QML-based Wayland shell). 

This repository contains an isolated testing environment (`test-hypr`) for experimentation alongside a custom status bar built from scratch with Quickshell.

---

## 🚀 Features

### 🏛️ Status Bar & Widgets (Quickshell)
- **Mathematical Screen Center Alignment:** Independent component anchoring ensures the center island (Clock) stays in the exact mathematical center of the screen regardless of left/right island sizes.
- **Sliding Workspace Pill:** Smooth `OutCubic` sliding animation (`Behavior on x`) when switching active workspaces, with accurate coordinate mapping via `mapToItem`.
- **Hybrid Workspace Model:** Displays base static workspaces (`I` to `V`) and dynamically appends extra workspaces (`VI`, `VII`, etc.) when active or occupied.
- **Logical Visual Hierarchy:**
  - **Active Workspace:** High-contrast dark text (`Theme.bgDark`) over the bright accent pill.
  - **Occupied Workspace:** Bright text (`Theme.textMain`) indicating running applications.
  - **Empty Workspace:** Muted 35% opacity text (`Theme.textMain` 0.35 alpha) to reduce visual clutter.
- **Reusable Popup Architecture (`BasePopup.qml`):**
  - Modular, extensible `PanelWindow` shell encapsulated in `widgets/BasePopup.qml`.
  - Built-in Wayland LayerShell setup (`WlrLayershell.namespace: "quickshell:popup"`), Hyprland glassmorphism blur, translucent Pywal background (`0.5` alpha), and dual slide/fade enter-exit animations.
  - Dynamic `updatePosition()` automatically centering any popup card precisely under its target status bar widget.
  - Native Qt 6 `HoverHandler` handling mouse events seamlessly without child widget event conflicts.
- **Unified Status Bar Pill Hover System:**
  - Standardized uniform pill hover rectangle (`height: 26px`, `radius: 8px`, translucent Pywal `0.15` background with `0.3` accent border) across all primary status bar widgets (`Clock.qml`, `MediaPlayer.qml`, `SystemStats.qml`).
- **Interactive Calendar & Date Hub (`Clock.qml` & `CalendarPopup.qml`):**
  - **Live Digital Header:** Displays real-time clock with seconds (`hh : mm : ss`) and full formatted date (*Senin, 10 Agustus 2026*).
  - **Interactive 7x6 Monthly Calendar Grid:**
    - Highlighting **Today** with a vibrant Pywal accent pill (`Theme.accent`) and high-contrast dark text.
    - **English Day Headers (`Sun`, `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat`):** Aligned 100% vertically over date columns using a shared 7-column `GridLayout` (`columnSpacing: 5`).
    - Month navigation controls: Previous Month (`󰅁`), Next Month (`󰅂`), and Today Reset (`󰃭`).
    - Dimmed dates for preceding and trailing month days.
  - **System Uptime Indicator:** Live system uptime parsed asynchronously via `Quickshell.Io` `Process` from `/proc/uptime` (e.g. `󰅐 System Uptime: 4j 12m`).
- **System Performance Monitor Dashboard (`SystemStats.qml` & `SysStatsPopup.qml`):**
  - **5-Circle Symmetrical Ring Gauge Layout:**
    - **CPU Load (`󰻠`):** Real-time processor utilization ring gauge with dynamic status badges (*Normal / High / Critical*).
    - **GPU Load (`󰢮`):** Real-time GPU utilization ring gauge powered by `nvidia-smi` and Linux DRM sysfs (`gpu_busy_percent`) fallback.
    - **CPU Temp (`󰔏`):** Thermal status ring gauge for CPU (*Good / Warm / Hot*).
    - **GPU Temp (`󰔏`):** Thermal status ring gauge for GPU (*Good / Warm / Hot*).
    - **Memory (`󰍛`):** Centered RAM utilization ring gauge with exact capacity metrics (*e.g. 10Gi / 15Gi*).
  - **Storage Disk Usage Bar:** Full-width progress bar tracking root `/` partition storage space (*e.g. 105G / 250G*).
  - **Enlarged Circular Ring Gauges ($115\times115\text{px}$):** Thickened 8px Canvas stroke width and vibrant color-coded metrics.
- **Dynamic MPRIS Media Player Widget (`MediaPlayer.qml`):**
  - Real-time media control powered natively by `Quickshell.Services.Mpris` (Spotify, Firefox/YouTube, Amberol, MPV, VLC, etc.) with **Smart-Select Active Player Filtering** prioritizing actively playing media over idle browser tabs.
  - Displays album art thumbnail (`trackArtUrl`), track title (`trackTitle`), and robust multi-fallback artist detection (`trackArtist`, `trackAlbumArtist`, `xesam:artist`).
  - **Seamless Infinite Continuous Marquee Loop:** Double-buffered linear text scrolling (`Easing.Linear`) that continuously loops track titles and artist names endlessly without abrupt jumps or gaps when text overflows.
  - **Real-Time PipeWire Cava Audio Visualizer Background:** 24-bar audio spectrum visualizer (`cava -p ~/.config/cava/config_quickshell`) rendered in the background (`z: 0`) spanning the full width of the container rectangle.
  - **Interactive Hover Detail Card (`MediaPopup.qml`):**
    - **Vertical Reference Layout:** Scaled $310\times450\text{px}$ floating popup card inheriting from `BasePopup`.
    - **1:1 Square Album Cover Art:** Large cover art ($278\times278\text{px}$) with smooth `QtQuick.Effects` `MultiEffect` rounded corner masking (`radius: 16`).
    - **Interactive Seek Progress Bar:** Click and drag to scrub track position in real-time (`player.seek()`), featuring a dynamic hover thumb indicator and active duration text highlights.
    - **Real-Time Position Ticker:** 1-second `posTicker` updating live playback position (`MM:SS`) and total duration smoothly.
    - **Optically Centered Controls:** Previous (`󰒮`), Play/Pause (`󰏤`/`󰐊` with $+1.5\text{px}$ optical center offset and $48\times48\text{px}$ button circle), and Next (`󰒭`).
  - Smart auto-hide animation when no media is actively playing.
- **Dynamic Pywal Theming & Smooth Transitions:** Real-time wallpaper color synchronization via a background `PywalService` (`StdioCollector` & polling), updating UI colors (`Theme.accent`, `Theme.bgDark`, `Theme.textMain`, `Theme.secondary`) with smooth `Easing.InOutQuad` color fade animations (`ColorAnimation`).
- **Dynamic System Statistics:**
  - **RAM Usage:** Real-time RAM usage with Nerd Font glyphs (`󰍛`).
  - **CPU Temperature:** Real-time CPU thermal status (`󰔏`).
  - **Dynamic Bluetooth Status:** Real-time Bluetooth connection state (`󰂯` connected vs `󰂲` disconnected with slash).
  - **Dynamic Wi-Fi Indicator:** Minimalist dynamic signal strength icon (`󰤨` / `󰤥` / `󰤢` / `󰤟` / `󰤮` disconnected) with SSID text hidden.
  - **Dynamic Battery State:** Smart battery status (`󰂄` charging, `󰁹` full) with automatic red warning color (`#f38ba8`) when battery drops below 20%.

### 🧪 Isolated Hyprland Test Environment (`test-hypr`)
- **Nested Testing Ready:** Rebound `$mainMod` to `ALT` to prevent keybind collisions with the host compositor during nested testing (`Hyprland -c ~/.config/test-hypr/hyprland.conf`).
- **Clean Canvas:** Autostart of legacy bars/notification daemons (Waybar, SwayNC, Hyprpaper) commented out to avoid UI overlaps with Quickshell.
- **Glassmorphism Layer Blur:** `layerrule = blur on` and `ignore_alpha 0.5` configured in `layerrule.conf` for both `quickshell` (status bar) and `quickshell:popup` (popup cards) namespaces.
- **Self-Contained Sourcing:** All sub-config files source explicitly from `~/.config/test-hypr/`.

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
    ├── shell.qml                   # Main entry point (Scope wrapper loading PywalService & Bar)
    ├── components/
    │   └── Bar.qml                 # Top Status Bar layout
    ├── theme/
    │   ├── Theme.qml               # Clean Singleton storing pure font & color properties
    │   └── PywalService.qml        # Background service syncing Pywal colors to Theme.qml
    ├── widgets/
    │   ├── BasePopup.qml           # Reusable PanelWindow popup shell with Hyprland blur & auto-positioning
    │   └── bar/
    │       ├── Workspace.qml       # Hybrid workspace switcher with sliding animation
    │       ├── Clock.qml           # Real-time clock & date widget with pill hover trigger
    │       ├── clockWidget/
    │       │   └── CalendarPopup.qml # Interactive monthly calendar, live clock & system uptime popup
    │       ├── MediaPlayer.qml     # Dynamic MPRIS media player entry point with pill hover trigger
    │       ├── mediaPlayerWidget/  # Dedicated modular sub-components
    │       │   ├── MarqueeText.qml # Reusable endless continuous marquee text
    │       │   ├── CavaVisualizer.qml # 24-bar PipeWire Cava audio visualizer
    │       │   └── MediaPopup.qml  # Floating hover detail card with interactive seek bar & 1:1 cover art
    │       ├── SystemStats.qml     # Dynamic stats widget with RAM/Temp pill hover trigger
    │       └── systemStatsWidget/
    │           └── SysStatsPopup.qml # 5-Circle Performance Dashboard popup (CPU/GPU Load & Temp, Mem, Storage)
    └── scripts/
        └── sys_info.sh             # Executable bash helper script for system metrics & GPU metrics
```

---

## 🛠️ Installation & Setup

### Prerequisites
Ensure the following packages are installed on your system (e.g. Arch Linux / CachyOS):
- `hyprland`
- `quickshell`
- `cava` (for real-time PipeWire audio visualizer)
- `pywal` (`wal`)
- `bluez` / `bluez-utils` (`bluetoothctl`)
- `qt6-declarative` / `qt6-5compat` / `qt6-shadertools` (for QML runtime, `QtQuick.Effects`, & `qmlformat`)
- `procps-ng` (`free`), `networkmanager` (`nmcli`), `bash`, `nvidia-utils` (optional for NVIDIA GPU stats)

### 1. Symlink Configuration (Recommended)
Link the repository directories to `~/.config/` so any edits sync automatically:

```bash
# Clone the repository
git clone https://github.com/RaihanDaiva/dotfiles-test.git ~/dotfiles-test

# Backup existing configs if necessary, then create symlinks
ln -sf ~/dotfiles-test/test-hypr ~/.config/test-hypr
ln -sf ~/dotfiles-test/quickshell ~/.config/quickshell

# Make helper script executable
chmod +x ~/.config/quickshell/scripts/sys_info.sh
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
