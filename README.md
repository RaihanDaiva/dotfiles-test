# ❄️ Dotfiles Test: Hyprland & Quickshell Ricing Setup

A modular, modern Linux desktop environment configuration built for **Hyprland** and **Quickshell** (QtQuick/QML-based Wayland shell). 

This repository contains an isolated testing environment (`test-hypr`) for experimentation alongside a custom status bar and popups built from scratch with Quickshell.

---

## 🚀 Features

### 🏛️ Status Bar & Multi-Monitor Widgets (Quickshell)
- **Multi-Monitor Native Architecture:** Instantiates the top status bar on all connected displays (`eDP-1` laptop display, `DP-1` external display, HDMI) via `Variants` over `Quickshell.screens`.
- **Mathematical Screen Center Alignment:** Independent component anchoring ensures the center island (Clock) stays in the exact mathematical center of the screen regardless of left/right island sizes.
- **Independent Per-Monitor Workspace Active Pill Tracking (`Workspace.qml`):**
  - Binds active workspace detection to `Hyprland.monitorFor(screen).activeWorkspace`.
  - Each monitor tracks and highlights its own active workspace independently (e.g. Workspace 1 highlighted on main monitor while Workspace 5 is highlighted on second monitor).
- **Special Workspace Indicator (`★`) & Negative Workspace ID Filtering:**
  - Filters out negative workspace IDs (`id > 0`) from regular workspace items, preventing scratchpad IDs (e.g. `-98`) from rendering on the left.
  - Adds a dedicated Special Workspace button (`★`) at the far right end of the workspace bar. When a scratchpad is focused, the sliding accent pill (`activePill`) smoothly moves to `★`.
- **Real-Time GTK Application Icons & Instance Count Dots (`Workspace.qml`):**
  - Background process streaming `hyprctl clients -j` to parse open window classes per workspace.
  - Maps window classes to system GTK/Freedesktop icons (`image://icon/`).
  - Displays open app icons to the right of each workspace Roman numeral.
  - Adds instance count indicator dots (`••`) beneath icons when multiple instances of the same application are open in a workspace.
  - **Dynamic Sliding Pill Width:** `activePill.width` smoothly expands and contracts (`Behavior on width`) to wrap around Roman numerals, app icons, and instance dots.
- **Modular 3-Widget Right Island Architecture:**
  - **SystemStats (`SystemStats.qml`):** Dedicated RAM usage & CPU temperature monitor pill triggering `SysStatsPopup`. Dynamic Pywal `Theme.accent` color applied across all status icons including CPU Temp (`󰔏`).
  - **ControlCenter (`ControlCenter.qml`):** Quick settings control pill (Brightness %, Volume %, Bluetooth, Wi-Fi, Battery %) triggering `QuickSettingsPopup` & `OsdPopup`. Restricted `eventMonitorProc` to primary screen (`Quickshell.screens[0]`) to eliminate duplicate OSD popups on multi-monitor setups.
  - **Power (`Power.qml`):** Standalone circular Power button (`󰐥`) triggering `PowerPopup`.
- **Logical Visual Hierarchy:**
  - **Active Workspace:** High-contrast dark text (`Theme.bgDark`) over the bright accent pill.
  - **Occupied Workspace:** Bright text (`Theme.textMain`) indicating running applications.
  - **Empty Workspace:** Muted 35% opacity text (`Theme.textMain` 0.35 alpha) to reduce visual clutter.
- **Floating Overlay Popups & LayerShell Exclusion Mode (`BasePopup.qml` & `components/popups/`):**
  - Reusable `PanelWindow` shell encapsulated in `widgets/BasePopup.qml`.
  - **`exclusionMode: ExclusionMode.Ignore`:** Applied across all popup windows (`BasePopup.qml`, `AppLauncherPopup.qml`, `WallpaperPopup.qml`, `OsdPopup.qml`, `PowerMenuOverlay.qml`, `NotificationPopup.qml`) ensuring popups float 100% cleanly over tiled windows without splitting or altering workspace tiling grids.
  - **Precise Below-Bar Positioning:** Dynamic top margin calculation (`margins.top: 54` or `barTop + barHeight + 6`) placing dropdown popups flush EXACTLY `6px` below the status bar.
  - Built-in Wayland LayerShell setup (`WlrLayershell.namespace: "quickshell:popup"`), Hyprland glassmorphism blur, translucent Pywal background (`0.5` alpha), and dual slide/fade enter-exit animations.
  - **Dynamic Wayland Keyboard Focus:** `requiresKeyboardFocus` property switching `WlrLayershell.keyboardFocus` dynamically to `WlrKeyboardFocus.OnDemand` whenever text input is active.
- **Power Button & Vertical Pill Power Menu (`PowerPopup.qml`):**
  - Dedicated circular Power button (`󰐥`) positioned cleanly as its own standalone pill widget on the right island.
  - **Vertical Pill Dropdown Menu (Opsi B):** Profile header with live uptime display + 5 rounded action pills for **Shutdown** (`systemctl poweroff`), **Reboot** (`systemctl reboot`), **Suspend** (`systemctl suspend`), **Lock Screen** (`hyprlock`), and **Log Out** (`hyprctl dispatch exit`).
- **Fullscreen Power Menu Overlay (`PowerMenuOverlay.qml`):**
  - Replaces `wlogout` with a native Quickshell overlay triggered by `Super + P` (`quickshell ipc call powermenu toggle`).
  - **Bottom-Center Floating Card:** Slide-up entrance animation (`Translate y: 50 → 0`) with dark backdrop overlay.
  - **Circle-to-Pill Morphing Animation:** Buttons default to compact circles ($64\times64\text{px}$) showing Nerd Font icons and expand into horizontal pills ($180\times64\text{px}$) on hover/selection to reveal action labels.
- **Custom Application Launcher (`AppLauncherPopup.qml`):**
  - Custom launcher triggered by `Alt + A` (`quickshell ipc call applauncher toggle`).
  - **Bottom-Center Overlay Layout:** Slide-up animation with top `ListView` app list and bottom search bar pill (`Search Apps`).
  - **Native Freedesktop Icon Provider:** Resolves system app GTK icons via `image://icon/<name>`.
- **Custom Wallpaper Selector (`WallpaperPopup.qml`):**
  - Custom wallpaper picker triggered by `Alt + W` (`quickshell ipc call wallpaperselect toggle`).
  - **Bottom-Center Overlay Layout:** Slide-up animation with top 5-item horizontal carousel ($16:9$ thumbnails) and bottom search bar pill (`Search Wallpapers`).
  - **Focused Config Directory Scanning (`wallpaper_list.sh`):** Scans wallpapers exclusively from `$HOME/.config/wallpapers/`.
  - **Active Wallpaper Persistence & Auto-Centering:** Detects current wallpaper on boot (`readlink -f ~/.cache/current_wallpaper.jpg`) and automatically highlights and centers it in the middle of the carousel (`ListView.Center`).
  - **Automated Pywal & Hyprpaper Execution (`apply_wallpaper.sh`):** Auto-starts `hyprpaper` if dead, applies wallpaper to all monitors, updates Pywal color scheme & Hyprland active border colors, and refreshes Cava.
- **Sequenced Popup Transition Manager (`shell.qml`):**
  - Built-in 200ms transition timer (`popupOpenTimer`) handling `requestOpen()` signals between `AppLauncherPopup` (`Alt + A`) and `WallpaperPopup` (`Alt + W`).
  - Ensures when switching between popups, the active popup slides down and closes completely BEFORE the new popup slides up smoothly onto a clean desktop.
- **Multi-Toast Stacked Notification Daemon & Overlay (`NotificationPopup.qml` & `NotificationServer`):**
  - Built directly on Quickshell's native DBus `NotificationServer` daemon (`Quickshell.Services.Notifications`).
  - **Multi-Toast Stacked Toast System:** Manages dynamic array model (`notifList`) supporting up to 4 stacked notification toasts vertically at top-right.
  - **Sequential Shift:** New notifications prepend to Row 1 (top), smoothly pushing older notifications down to Row 2, Row 3, etc.
  - **Smooth Horizontal Slide Animations:** IN animation slides from far right screen edge (`+400px` $\rightarrow$ `0px`), OUT animation slides back to far right (`0px` $\rightarrow$ `+400px`).
  - **Independent Timers & Dismissal:** Individual 5-second auto-dismiss timers and `✖` close buttons per card, with remaining toasts smoothly sliding up on dismissal.
  - **Reliable Property Assignment:** Explicit property binding in `showNotification()` for 100% reliable app name, summary, body text, and GTK app icon rendering.
- **Real-Time On-Screen Display (OSD) Overlay (`OsdPopup.qml`):**
  - Floating bottom-centered glassmorphism overlay card (`WlrLayer.Overlay`) rendering real-time volume and brightness indicators with smooth `OutCubic` entrance/exit animations.
  - **0ms Real-Time Event Listener (`sys_event_monitor.sh`):** Streams PipeWire audio events via `pactl subscribe` and Linux kernel backlight events via `udevadm monitor --subsystem-match=backlight` for instant OSD updates when adjusting volume or brightness via keyboard **Fn** shortcuts.
- **System Performance Dashboard (`SysStatsPopup.qml`):**
  - **5-Circle Symmetrical Ring Gauge Layout:** CPU Load (`󰻠`), GPU Load (`󰢮`), CPU Temp (`󰔏`), GPU Temp (`󰔏`), and Memory (`󰍛`).
  - **Storage Disk Usage Bar:** Full-width progress bar tracking root `/` partition storage space.
- **Windows 11 Style Control Center Hub (`QuickSettingsPopup.qml`):**
  - **3-Page Horizontal Sliding Drill-Down Navigation:** Main Page, Detail List Page (scanned Wi-Fi & paired Bluetooth), and Wi-Fi Password Input Page.
  - **Volume Overamplification (0%–150% Boost):** Volume boost up to **150%** via `wpctl`.
  - **Dynamic Multi-Monitor Screen Brightness Detection:** Supports internal panels (`brightnessctl`) and external displays via DDC/CI (`ddcutil`).

---

## 📂 Repository Structure

```text
dotfiles-test/
├── test-hypr/                      # Isolated Hyprland configuration
│   ├── hyprland.conf               # Core Hyprland configuration (sourcing ~/.config/hypr files)
│   ├── autostart.conf              # Autostart applications & background daemons (hyprpaper, restore-wallpaper.sh & quickshell)
│   ├── keybinds.conf               # Rebound shortcuts ($mainMod = ALT, Super + P powermenu, Alt + A applauncher, Alt + W wallpaperselect)
│   ├── input.conf                  # Keyboard layout & touchpad settings
│   ├── layerrule.conf              # Blur & window rules (ignore_alpha 0.5 for quickshell & quickshell:popup)
│   ├── monitors.conf               # Display monitor setup
│   └── scripts/                    # Wallpaper & utility scripts (set-wallpaper.sh, restore-wallpaper.sh, etc.)
│
└── quickshell/                     # Quickshell UI configuration
    ├── shell.qml                   # Main entry point (Scope loading PywalService, Bar variants, NotificationServer, PowerMenuOverlay, AppLauncherPopup & WallpaperPopup)
    ├── components/
    │   ├── Bar.qml                 # Top Status Bar layout receiving screen property
    │   └── popups/                 # 🪟 CENTRALIZED POPUP REPOSITORY
    │       ├── CalendarPopup.qml   # Interactive monthly calendar, live clock & uptime popup
    │       ├── MediaPopup.qml      # Floating detail card with 1:1 cover art, seek bar & playback controls
    │       ├── SysStatsPopup.qml   # 5-Circle Performance Dashboard popup (CPU/GPU Load & Temp, Mem, Storage)
    │       ├── QuickSettingsPopup.qml # Windows 11 style 3-tier sliding Control Center popup
    │       ├── OsdPopup.qml        # Real-time OSD overlay card for Volume & Brightness (exclusionMode: Ignore)
    │       ├── NotificationPopup.qml # Multi-toast stacked notification popup extending PanelWindow with slide animations
    │       ├── PowerPopup.qml      # Power menu popup dropdown extending BasePopup
    │       ├── PowerMenuOverlay.qml # Fullscreen Power Menu Overlay with Morphing Circle-to-Pill buttons (Super + P)
    │       ├── AppLauncherPopup.qml # Application Launcher popup extending PanelWindow with bottom-center search bar (Alt + A)
    │       └── WallpaperPopup.qml  # Horizontal Wallpaper Selector Carousel popup extending PanelWindow (Alt + W)
    ├── theme/
    │   ├── Theme.qml               # Clean Singleton storing pure font & color properties
    │   └── PywalService.qml        # Background service syncing Pywal colors to Theme.qml
    ├── widgets/
    │   ├── BasePopup.qml           # Reusable PanelWindow popup shell with dynamic Wayland keyboard focus, exclusionMode: Ignore & 54px top margin
    │   ├── ControlPill.qml         # Reusable control button pill with optical center offset
    │   └── bar/
    │       ├── Workspace.qml       # Independent per-monitor workspace switcher with GTK app icons, instance dots & special workspace indicator (★)
    │       ├── Clock.qml           # Real-time clock & date widget with pill hover trigger
    │       ├── MediaPlayer.qml     # Dynamic MPRIS media player entry point with dual MarqueeText column
    │       ├── mediaPlayerWidget/  # Sub-components for media player
    │       │   ├── MarqueeText.qml # Reusable endless continuous marquee text
    │       │   └── CavaVisualizer.qml # 24-bar PipeWire Cava audio visualizer
    │       ├── SystemStats.qml     # RAM & CPU Temp performance monitor widget
    │       ├── ControlCenter.qml   # Quick settings control pill widget (Brightness/Vol/BT/WiFi/Bat) with single-instance event monitor
    │       └── Power.qml           # Standalone Power button widget
    └── scripts/
        ├── sys_info.sh             # Executable bash helper script for system metrics, GPU stats & volume
        ├── sys_event_monitor.sh    # Real-time event streamer for PipeWire audio & kernel backlight
        ├── brightness_info.sh      # Helper script detecting internal and DDC/CI external display brightness
        ├── wifi_list.sh            # Helper script parsing unique signal-sorted Wi-Fi networks via nmcli
        ├── bt_list.sh              # Helper script parsing Bluetooth device status and clean names via pipe delimiter
        ├── wallpaper_list.sh       # Helper script parsing wallpapers exclusively from ~/.config/wallpapers/
        └── apply_wallpaper.sh      # Executable script setting hyprpaper, pywal colors, hyprland borders & cava
```

---

## 🛠️ Installation & Setup

### Prerequisites
Ensure the following packages are installed on your system (e.g. Arch Linux / CachyOS):
- `hyprland`
- `quickshell`
- `hyprpaper`
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
ln -sf ~/dotfiles-test/test-hypr ~/.config/hypr
ln -sf ~/dotfiles-test/quickshell/han-dots ~/.config/quickshell
ln -sf ~/dotfiles-test/niri ~/.config/niri

# Make helper scripts executable
chmod +x ~/dotfiles-test/quickshell/han-dots/scripts/*.sh
```

### 2. Testing in Nested Hyprland
Launch the isolated testing environment in a window:

```bash
Hyprland -c ~/.config/hypr/hyprland.conf
```

### 3. Launching Quickshell
Inside your Hyprland testing session, launch Quickshell from a terminal:

```bash
quickshell
```

---

## 🎨 Keyboard Shortcuts (Hyprland Session)

| Shortcut | Action |
| :--- | :--- |
| `Super + Return` | Open Terminal (Kitty) |
| `Alt + A` | Open Custom Quickshell App Launcher |
| `Alt + W` | Open Custom Quickshell Wallpaper Selector |
| `Super + P` | Open Custom Quickshell Power Menu Overlay |
| `Alt + Q` | Close Active Window |
| `Alt + M` | Exit Hyprland Session |
| `Alt + 1` .. `Alt + 5` | Switch Workspaces |

---

## 🧩 Keyboard Shortcuts Cheatsheet (Niri Compositor Session)

### 🚀 Custom Quickshell & General Launchers
| Shortcut | Action |
| :--- | :--- |
| `Mod + Return` | Open Terminal (Kitty) |
| `Alt + A` / `Mod + Space` | Open Custom Quickshell App Launcher (`applauncher toggle`) |
| `Alt + W` / `Ctrl + Alt + T` | Open Custom Quickshell Wallpaper Selector (`wallpaperselect toggle`) |
| `Super + P` / `Mod + Shift + Q` | Open Fullscreen Power Menu Overlay (`powermenu toggle`) |
| `Mod + V` | Open Clipboard History (`cliphist`) |
| `Mod + Alt + L` | Lock Screen (`hyprlock`) |

### 🪟 Window & Layout Management
| Shortcut | Action |
| :--- | :--- |
| `Mod + Q` | Close Active Window |
| `Mod + D` | Maximize Column (Fills width, preserves gaps/bar) |
| `Mod + F` | Toggle Fullscreen Window (Borderless edge-to-edge) |
| `Mod + A` | Toggle Window Floating / Tiling |
| `Mod + Shift + V` | Switch Focus between Floating and Tiling Layers |
| `Mod + R` | Cycle Preset Column Width ($1/3 \rightarrow 1/2 \rightarrow 2/3$) |
| `Mod + C` | Center Focused Column on Screen |
| `Mod + Ctrl + R` | Reset Window Height |
| `Mod + -` / `Mod + =` | Adjust Column Width ($-10\%$ / $+10\%$) |
| `Mod + Shift + -` / `Mod + Shift + =` | Adjust Window Height ($-10\%$ / $+10\%$) |
| `Mod + [` / `Mod + ]` | Consume or Expel Window Left / Right |

### 🎯 Focus & Window Navigation
| Shortcut | Action |
| :--- | :--- |
| `Mod + Left` / `Mod + H` | Focus Column Left |
| `Mod + Right` / `Mod + L` | Focus Column Right |
| `Mod + Up` / `Mod + K` | Focus Window Up |
| `Mod + Down` / `Mod + J` | Focus Window Down |
| `Mod + Home` / `Mod + End` | Jump to First / Last Column |
| `Alt + Tab` / `Alt + Shift + Tab` | Cycle Recent Windows |
| `Mod + Shift + Left / Right / Up / Down` | Move Column Left / Right / Window Up / Down |
| `Mod + Ctrl + Home / End` | Move Column to First / Last Position |

### 🖥️ Multi-Monitor & Workspace Navigation
| Shortcut | Action |
| :--- | :--- |
| `Alt + 1` .. `Alt + 5` | Focus Workspace 1 to 5 |
| `Super + Shift + 1` .. `Super + Shift + 5` | Move Column to Workspace 1 to 5 |
| `Mod + 1` .. `Mod + 9` | Focus Workspace 1 to 9 (Niri Native) |
| `Mod + Ctrl + 1` .. `Mod + Ctrl + 9` | Move Column to Workspace 1 to 9 |
| `Mod + Page_Down` / `Mod + Page_Up` | Focus Workspace Down / Up |
| `Mod + WheelScrollDown / Up` | Mouse Scroll Workspace Down / Up |
| `Mod + Ctrl + Left / Right / Up / Down` | Focus Monitor in Direction |
| `Mod + Ctrl + Shift + Left / Right / Up / Down` | Move Column to Monitor in Direction |

### 📸 Screenshots & Media Controls
| Shortcut | Action |
| :--- | :--- |
| `Print` | Capture Full Screen |
| `Ctrl + Print` | Capture Active Screen |
| `Alt + Print` | Capture Active Window |
| `Mod + Shift + S` | Region Screenshot (`grim -g "$(slurp)" - \| wl-copy`) |
| `Mod + Shift + R` | Screen Recording (`gpu-screen-recorder-gtk`) |
| `XF86AudioRaiseVolume` / `LowerVolume` | Adjust Volume (PipeWire `wpctl`) |
| `XF86AudioMute` | Mute Audio (`wpctl`) |
| `XF86MonBrightnessUp` / `Down` | Adjust Screen Brightness (`brightnessctl`) |
| `XF86AudioPlay` / `Pause` / `Next` / `Prev` | Media Playback Controls (`playerctl`) |

---

## 📝 Maintenance & Contribution
This `README.md` is updated regularly alongside repository commits to reflect current features, directory structures, and code architecture changes.

