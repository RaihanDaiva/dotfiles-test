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
- **Dynamic MPRIS Media Player Widget (`MediaPlayer.qml`):**
  - Real-time media control powered natively by `Quickshell.Services.Mpris` (Spotify, Firefox/YouTube, Amberol, MPV, VLC, etc.).
  - Displays album art thumbnail (`trackArtUrl`), track title (`trackTitle`), and artist name (`trackArtists`).
  - Interactive playback control buttons: Previous (`󰒮`), Play/Pause (`󰏤`/`󰐊`), and Next (`󰒭`).
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
- **Clean Layer Blur:** `ignore_alpha 0.5` layerrule configured in `layerrule.conf` so Hyprland blurs the status bar with clean rounded corners without blurring transparent margin gaps.
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
│   ├── layerrule.conf              # Blur & window rules (ignore_alpha 0.5 for Quickshell)
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
    │   └── Bar/
    │       ├── Workspace.qml       # Hybrid workspace switcher with sliding animation
    │       ├── Clock.qml           # Real-time clock & date widget
    │       ├── MediaPlayer.qml     # Dynamic MPRIS media player widget
    │       └── SystemStats.qml     # Dynamic stats widget (RAM, CPU, Bluetooth, Wi-Fi, Battery)
    └── scripts/
        └── sys_info.sh             # Executable bash helper script for system metrics
```

---

## 🛠️ Installation & Setup

### Prerequisites
Ensure the following packages are installed on your system (e.g. Arch Linux / CachyOS):
- `hyprland`
- `quickshell`
- `pywal` (`wal`)
- `bluez` / `bluez-utils` (`bluetoothctl`)
- `qt6-declarative` / `qt5-declarative` (for QML runtime & `qmlformat`)
- `procps-ng` (`free`), `networkmanager` (`nmcli`), `bash`

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
