# ❄️ Dotfiles Test: Hyprland & Quickshell Ricing Setup

A modular, modern Linux desktop environment configuration built for **Hyprland** and **Quickshell** (QtQuick/QML-based Wayland shell). 

This repository contains an isolated testing environment (`test-hypr`) for experimentation alongside a custom 3-island status bar built from scratch with Quickshell.

---

## 🚀 Features

### 🏛️ 3-Island Status Bar (Quickshell)
- **Mathematical Screen Center Alignment:** Independent component anchoring ensures the center island (Clock) stays in the exact mathematical center of the screen regardless of left/right island sizes.
- **Sliding Workspace Pill:** Smooth `OutCubic` sliding animation (`Behavior on x`) when switching active workspaces, with accurate coordinate mapping via `mapToItem`.
- **Hybrid Workspace Model:** Displays base static workspaces (`I` to `V`) and dynamically appends extra workspaces (`VI`, `VII`, etc.) when active or occupied.
- **Roman Numeral Indicators:** Clean, aesthetic workspace representation (`I` through `X`).
- **Live System Statistics:** Real-time RAM usage, CPU temperature, Battery level, and active Wi-Fi SSID powered by a lightweight asynchronous bash script.

### 🧪 Isolated Hyprland Test Environment (`test-hypr`)
- **Nested Testing Ready:** Rebound `$mainMod` to `ALT` to prevent keybind collisions with the host compositor during nested testing (`Hyprland -c ~/.config/test-hypr/hyprland.conf`).
- **Clean Canvas:** Autostart of legacy bars/notification daemons (Waybar, SwayNC, Hyprpaper) commented out to avoid UI overlaps with Quickshell.
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
│   ├── monitors.conf               # Display monitor setup
│   └── scripts/                    # Wallpaper & utility scripts
│
└── quickshell/                     # Quickshell UI configuration
    ├── shell.qml                   # Main entry point (Scope wrapper)
    ├── components/
    │   └── Bar.qml                 # 3-Island Top Status Bar layout
    ├── widgets/
    │   └── Bar/
    │       ├── Workspace.qml       # Hybrid workspace switcher with sliding animation
    │       ├── Clock.qml           # Real-time clock & date widget
    │       └── SystemStats.qml     # System stats widget (RAM, CPU, Battery, Wi-Fi)
    └── scripts/
        └── sys_info.sh             # Executable bash helper script for system metrics
```

---

## 🛠️ Installation & Setup

### Prerequisites
Ensure the following packages are installed on your system (e.g. Arch Linux / CachyOS):
- `hyprland`
- `quickshell`
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
