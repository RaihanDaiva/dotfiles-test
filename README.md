# ❄️ Dotfiles Test: Hyprland & Quickshell Ricing Setup

A modular, modern Linux desktop environment configuration built for **Hyprland**, **Niri**, and **Quickshell** (QtQuick/QML-based Wayland shell). 

This repository contains an isolated testing environment (`test-hypr`) for experimentation alongside a custom status bar, desktop widgets, and popups built from scratch with Quickshell.

---

## 🚀 Features

### 🔐 Native Wayland Lockscreen (`Lockscreen.qml`)
- **Native Wayland Session Lock (`WlSessionLock` & `WlSessionLockSurface`):** Securely locks the desktop session via the `ext-session-lock-v1` protocol.
- **Native Linux PAM Authentication (`PamContext`):** Verifies user credentials directly against PAM (`Quickshell.Services.Pam`), returning smooth visual feedback on success or failure.
- **Instant System Wallpaper Background:** Synchronously loads the current active wallpaper from `~/.cache/current_wallpaper.jpg` with texture caching from frame 0.
- **Constant Dark Translucent Overlay:** Translucent dark backdrop (`Theme._darkBg` at 65% opacity) and high-contrast light text (`Theme._darkText`) remaining constant in both Light and Dark modes.
- **Circular User Avatar & Centered Password Field:** HD circular profile picture with `MultiEffect` mask positioned above username and centered password text input (`horizontalAlignment: AlignHCenter`).
- **Lockscreen Media Player Card:** Scaled-up rounded rectangle card below `LargeClock` featuring album cover, marquee scrolling track title & artist, playback controls (Prev, Play/Pause, Next), and a frosted glass album art background with `OpacityMask` corner clipping.
- **Guaranteed Keyboard Focus (`FocusScope` & `Keys`):** Top-level `FocusScope` capturing all keypresses including `Return`/`Enter`, `Backspace`, and `Escape`, ensuring instant keyboard focus without requiring manual mouse clicks.
- **Smooth Fade-In & Fade-Out Transitions:** 400ms entrance fade-in and 350ms exit fade-out sequence on the 65% Pywal translucent dark overlay before releasing the Wayland session lock.
- **Zero-Shift Status Message Slot:** Fixed 24px reserved slot for authentication messages (`Authenticating...` / `Incorrect password`), completely preventing layout shifting or field jumping when feedback appears.
- **IPC Control:** Triggerable via keyboard binds or terminal using `quickshell ipc call lockscreen lock` / `toggle`.

### 🏛️ Status Bar & Multi-Monitor Widgets (Quickshell)
- **Multi-Monitor Native Architecture:** Instantiates the top status bar on all connected displays (`eDP-1` laptop display, `DP-1` external display, HDMI) via `Variants` over `Quickshell.screens`.
- **Mathematical Screen Center Alignment:** Independent component anchoring ensures the center island (Clock) stays in the exact mathematical center of the screen regardless of left/right island sizes.
- **iNiR-Style Multi-Monitor Workspace Engine (`Workspace.qml`):**
  - **Main Monitor (Laptop `eDP-1`):** Holds Workspaces 1..5 (`baseWsId = 1`), visually displaying Roman numerals `I`, `II`, `III`, `IV`, `V`.
  - **Second Monitor (`DP-1` / HDMI):** Holds Workspaces 6..10 (`baseWsId = 6`), visually displaying Roman numerals `I`, `II`, `III`, `IV`, `V` (`1..5`).
  - **Per-Monitor Active Rectangle & App Icons:** Independent accent pill sliding smoothly per monitor. App icons are filtered per display output (`client.output === screenName`).
  - **Dynamic Next-Workspace Display (`Occupied + 1 Next Workspace`):** Dynamically calculates visible workspace buttons based on occupied workspaces + 1 next empty workspace (capped at 5), eliminating empty workspace button clutter.
- **Wayland LayerShell Surface Masking (`Region { item: card }`):**
  - Applied `mask: Region { item: container }` across `Bar.qml`, `AppLauncherPopup.qml`, `WallpaperPopup.qml`, and `BasePopup.qml`.
  - Clips Wayland LayerShell surface geometry precisely to 20px rounded card corners, erasing sharp square background box artifacts behind popups.
- **Frosted Glass Status Bar Backdrop Blur:**
  - Configured `WlrLayershell.namespace: "quickshell:bar"` with 65% translucent background opacity.
  - Paired with Niri `layer-rule { match namespace="quickshell:bar" geometry-corner-radius 20 background-effect { blur true } }` for 60FPS frosted glass status bar backdrop blur.
- **Niri Wiki Teknik 2 Dual-Wallpaper Engine (`apply_wallpaper.sh` & `restore-wallpaper.sh`):**
  - **Crisp Workspace Wallpaper:** Rendered via `awww-daemon` (60FPS smooth circle grow/outer transition animation) on normal workspace cards.
  - **Blurred Overview Backdrop Wallpaper:** Automatically generated via ImageMagick (`magick -resize 50% -blur 0x25`) and rendered via `swaybg` (`namespace="^wallpaper$" place-within-backdrop true`) on Niri's overview backdrop.
  - **Dynamic Pywal Active Window Border Sync:** Automatically extracts Pywal colors and updates Niri's `focus-ring { active-gradient from="$color11" to="$color14" angle=45 }` inside `20-layout-and-overview.kdl` on every wallpaper change.
- **Special Workspace Indicator (`★`) & Negative Workspace ID Filtering:**
  - Filters out negative workspace IDs (`id > 0`) from regular workspace items, preventing scratchpad IDs (e.g. `-98`) from rendering on the left.
  - Adds a dedicated Special Workspace button (`★`) at the far right end of the workspace bar. When a scratchpad is focused, the sliding accent pill (`activePill`) smoothly moves to `★`.
- **Real-Time GTK Application Icons & Instance Count Dots (`Workspace.qml`):**
  - Background process streaming `niri msg -j windows` / `hyprctl clients -j` to parse open window classes per workspace.
  - Maps window classes to system GTK/Freedesktop icons (`image://icon/`).
  - Displays open app icons to the right of each workspace Roman numeral.
  - Adds instance count indicator dots (`••`) beneath icons when multiple instances of the same application are open in a workspace.
  - **Dynamic Sliding Pill Width:** `activePill.width` smoothly expands and contracts (`Behavior on width`) to wrap around Roman numerals, app icons, and instance dots.
- **Modular 4-Widget Right Island Architecture:**
  - **SystemStats (`SystemStats.qml`):** Dedicated RAM usage & CPU temperature monitor pill triggering `SysStatsPopup`. Dynamic Pywal `Theme.accent` color applied across all status icons including CPU Temp (`󰔏`).
  - **ControlCenter (`ControlCenter.qml`):** Quick settings control pill (Brightness %, Volume %, Bluetooth, Wi-Fi, Battery %) triggering `QuickSettingsPopup` & `OsdPopup`. Restricted `eventMonitorProc` to primary screen (`Quickshell.screens[0]`) to eliminate duplicate OSD popups on multi-monitor setups.
  - **NotificationPill (`NotificationPill.qml`):** Dedicated notification bell button (`󰂚` / `󱅫`) with real-time unread badge count positioned between ControlCenter and Power, triggering `NotificationCenterPopup`.
  - **Power (`Power.qml`):** Standalone circular Power button (`󰐥`) triggering `PowerPopup`.
- **🔔 Full Notification Center & Toast Popups with App Redirection (`NotificationCenterPopup.qml`, `NotificationPopup.qml`, `NotificationStore.qml`):**
  - Extends `BasePopup.qml` with glassmorphism blur and rounded corners.
  - Features real-time unread badge counter, empty state (`No Notifications`), scrollable notification list with app icons, timestamps, individual item dismiss buttons (`✖`), and a **"Clear All" button** (`󰎟 Clear All`) at the very bottom.
  - **Interactive App Redirection:** Clicking any notification card (toast or notification center item) automatically invokes default notification actions and switches workspaces to focus the target application window in Niri (`niri msg action focus-window --id <win_id>`) with dynamic alias matching for Discord, Vesktop, Spotify, Zen, Firefox, Telegram, Code, etc.
- **⚡ Wi-Fi & Bluetooth QuickSettings Control (`QuickSettingsPopup.qml`):**
  - Interactive Disconnect pill buttons (`#f38ba8`) for active Wi-Fi connections (`nmcli connection down`) and Bluetooth devices (`bluetoothctl disconnect`).
  - **Saved Network Auto-Connect:** Clicking "Connect" on previously saved Wi-Fi networks connects instantly using saved NetworkManager credentials without requiring re-entering passwords.
- **🎵 Frosted Blurred Album Art Media Popup (`MediaPopup.qml`):**
  - Modular media popup architecture located in `components/popups/mediaPopup/` supporting dynamic layout switching (**Classic** 310×485px & **Minimalist** 370×155px compact view).
  - Features 1:1 cover art, seek bar, playback controls, and atmospheric frosted blurred album art background (`FastBlur` radius 40, `OpacityMask` radius 18, and translucent dark overlay).
  - **Dynamic Theme & Opacity Fallback:** Automatically resolves background tint using `Theme.bgDark` in both Light and Dark modes. When cover art blur is disabled, outer frosted overlay hides completely to respect global popup opacity settings.
- **⚙️ Elements & Popup Customizer Window (`settingsPopup/SettingsPopup.qml` & `SettingsStore.qml`):**
  - **Standalone Draggable Window:** Floating overlay window with draggable header handle (`MouseArea`), smooth screen auto-centering (`Component.onCompleted`), and `WlrLayershell` overlay layer.
  - **Sidebar Navigation Panel:** Clean left-side navigation panel (140px width) with category selection (e.g. `🪟 Popups`).
  - **Modular Category Page Architecture (`category/PopupsCategory.qml`):** Dynamic category loading via `Loader` separating customization pages cleanly.
  - **Custom Styled UI Controls:**
    - `CustomSlider`: 6px thin track with `Theme.accent` progress bar and 16px circular thumb handle.
    - `CustomSwitch`: 46×24px pill track with smooth color animations and 18px inner circle knob (`Theme.bgDark` on active pill).
  - **Live Customization Options:** Real-time controls for Global Popup Opacity (50%–100%), Corner Radius (10px–28px), Border Width (0px–8px), Frosted Album Art Background toggle, and Media Player Layout Style selector (`Classic` vs `Minimalist`).
  - **Persistent JSON Configuration (`services/SettingsStore.qml`):** Automatically saves and loads all user preferences to `~/.config/quickshell/settings.json`, including Light/Dark mode state and window open state across Quickshell restarts.
  - **QuickSettings Integration (`QuickSettingsPopup.qml`):** Dedicated gear button (`󰒓`) in the ControlCenter header for instant access to the customizer window.
- **🪟 Mutually Exclusive Popup Manager (`PopupManager.qml`):**
  - Centralized singleton (`PopupManager.qml`) integrated directly into `BasePopup.qml` (`onIsOpenChanged`).
  - Automatically closes any previously active dropdown popup whenever a new popup is opened, completely preventing popup stacking/overlapping.
- **🖱️ Refined Activation Modes (On-Click Only vs Hover):**
  - **On-Click Only (`Click to Toggle`):** Applied to ControlCenter, NotificationPill, SystemStats, and Power to prevent accidental triggers and ensure stable slider/list interaction.
  - **Hover & Click:** Preserved on `Clock.qml` for quick monthly calendar previews.
- **Logical Visual Hierarchy:**
  - **Active Workspace:** High-contrast dark text (`Theme.bgDark`) over the bright accent pill.
  - **Occupied Workspace:** Bright text (`Theme.textMain`) indicating running applications.
  - **Empty Workspace:** Muted 35% opacity text (`Theme.textMain` 0.35 alpha) to reduce visual clutter.
- **Floating Overlay Popups & LayerShell Exclusion Mode (`BasePopup.qml` & `components/popups/`):**
  - Reusable `PanelWindow` shell encapsulated in `widgets/BasePopup.qml`.
  - **`exclusionMode: ExclusionMode.Ignore`:** Applied across all popup windows (`BasePopup.qml`, `AppLauncherPopup.qml`, `WallpaperPopup.qml`, `OsdPopup.qml`, `PowerMenuOverlay.qml`, `NotificationPopup.qml`, `NotificationCenterPopup.qml`) ensuring popups float 100% cleanly over tiled windows without splitting or altering workspace tiling grids.
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
  - **Automated Pywal, Awww & Swaybg Execution (`apply_wallpaper.sh`):** Applies 60FPS awww transition on workspace cards, generates & applies ImageMagick blurred wallpaper on Niri overview backdrop via `swaybg`, updates Pywal color scheme & active window gradient borders, and refreshes Cava.
- **Sequenced Popup Transition Manager (`shell.qml`):**
  - Built-in 200ms transition timer (`popupOpenTimer`) handling `requestOpen()` signals between `AppLauncherPopup` (`Alt + A`) and `WallpaperPopup` (`Alt + W`).
  - Ensures when switching between popups, the active popup slides down and closes completely BEFORE the new popup slides up smoothly onto a clean desktop.

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
    ├── shell.qml                   # Main entry point (Scope loading PywalService, Bar variants, DesktopClock, Lockscreen, NotificationServer, etc.)
    ├── components/
    │   ├── Bar.qml                 # Top Status Bar layout receiving screen property
    │   ├── DesktopClock.qml        # Wayland Desktop LayerShell surface wrapper for LargeClock
    │   ├── Lockscreen.qml          # 🔐 Native Wayland Session Lock widget with PAM Auth & Underline input field
    │   └── popups/                 # 🪟 CENTRALIZED POPUP REPOSITORY
    │       ├── CalendarPopup.qml   # Interactive monthly calendar, live clock & uptime popup
    │       ├── MediaPopup.qml      # Floating detail card with 1:1 cover art, seek bar & playback controls
    │       ├── SysStatsPopup.qml   # 5-Circle Performance Dashboard popup (CPU/GPU Load & Temp, Mem, Storage)
    │       ├── QuickSettingsPopup.qml # Windows 11 style 3-tier sliding Control Center popup
    │       ├── NotificationCenterPopup.qml # Notification Center popup extending BasePopup with Clear All button
    │       ├── OsdPopup.qml        # Real-time OSD overlay card for Volume & Brightness (exclusionMode: Ignore)
    │       ├── NotificationPopup.qml # Multi-toast stacked notification popup extending PanelWindow with slide animations
    │       ├── PowerPopup.qml      # Power menu popup dropdown extending BasePopup
    │       ├── PowerMenuOverlay.qml # Fullscreen Power Menu Overlay with Morphing Circle-to-Pill buttons (Super + P)
    │       ├── AppLauncherPopup.qml # Application Launcher popup extending PanelWindow with bottom-center search bar (Alt + A)
    │       └── WallpaperPopup.qml  # Horizontal Wallpaper Selector Carousel popup extending PanelWindow (Alt + W)
    ├── services/
    │   ├── NotificationStore.qml   # Central Singleton tracking active notification list
    │   └── PopupManager.qml        # Central Singleton enforcing mutually exclusive popup behavior
    ├── theme/
    │   ├── Theme.qml               # Clean Singleton storing pure font & color properties
    │   └── PywalService.qml        # Background service syncing Pywal colors to Theme.qml
    ├── widgets/
    │   ├── BasePopup.qml           # Reusable PanelWindow popup shell with PopupManager integration & 54px top margin
    │   ├── ControlPill.qml         # Reusable control button pill with optical center offset
    │   ├── LargeClock.qml          # Minimalist 2-line desktop clock widget using Theme.fontMain
    │   └── bar/
    │       ├── Workspace.qml       # Independent per-monitor workspace switcher with GTK app icons, instance dots & special workspace indicator (★)
    │       ├── Clock.qml           # Real-time clock & date widget with pill hover trigger
    │       ├── MediaPlayer.qml     # Dynamic MPRIS media player entry point with dual MarqueeText column
    │       ├── mediaPlayerWidget/  # Sub-components for media player
    │       │   ├── MarqueeText.qml # Reusable endless continuous marquee text
    │       │   └── CavaVisualizer.qml # 24-bar PipeWire Cava audio visualizer
    │       ├── SystemStats.qml     # RAM & CPU Temp performance monitor widget
    │       ├── ControlCenter.qml   # Quick settings control pill widget (Brightness/Vol/BT/WiFi/Bat)
    │       ├── NotificationPill.qml # Standalone notification bell button with unread count badge
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
- `hyprland` / `niri`
- `quickshell`
- `hyprpaper` / `awww` / `swaybg`
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

| Shortcut               | Action                                    |
| :--------------------- | :---------------------------------------- |
| `Super + Return`       | Open Terminal (Kitty)                     |
| `Alt + A`              | Open Custom Quickshell App Launcher       |
| `Alt + W`              | Open Custom Quickshell Wallpaper Selector |
| `Super + P`            | Open Custom Quickshell Power Menu Overlay |
| `Super + Alt + L`      | Lock Screen Native Quickshell (`lockscreen lock`) |
| `Alt + Q`              | Close Active Window                       |
| `Alt + M`              | Exit Hyprland Session                     |
| `Alt + 1` .. `Alt + 5` | Switch Workspaces                         |

---

## 🧩 Keyboard Shortcuts Cheatsheet (Niri Compositor Session)

### 🚀 Custom Quickshell & General Launchers
| Shortcut | Action |
| :--- | :--- |
| `Mod + Return` | Open Terminal (Kitty) |
| `Alt + A` / `Super + A` | Open Custom Quickshell App Launcher (`applauncher toggle`) |
| `Alt + W` / `Super + W` / `Ctrl + Alt + T` | Open Custom Quickshell Wallpaper Selector (`wallpaperselect toggle`) |
| `Super + P` / `Mod + Shift + Q` | Open Fullscreen Power Menu Overlay (`powermenu toggle`) |
| `Mod + Alt + L` | Lock Screen Native (`quickshell ipc call lockscreen lock`) |
| `Mod + Space` | Open App Launcher (`applauncher toggle`) |
| `Mod + V` | Open Clipboard History (`cliphist list \| wofi --dmenu \| ...`) |

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
| `Alt + Tab` / `Alt + Shift + Tab` | Cycle Recent Windows (`recent-windows` preview) |
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

## 🎨 Window Effects & Blur Rules (Niri Compositor)

To enable smooth window backdrop blur and rounded corners without punching through to the wallpaper, Niri uses the following `window-rule` in `niri/config.d/90-user-extra.kdl`:

```kdl
// 📱 Application Window Blur & Rounding Rules
window-rule {
    background-effect {
        blur true
        xray false // Blur underlying windows instead of jumping to wallpaper
    }
    geometry-corner-radius 14
    clip-to-geometry true
}

// 🪟 Active / Inactive Opacity Rules
window-rule {
    match is-active=true
    opacity 0.95
}

window-rule {
    match is-active=false
    opacity 0.80
}
```

---

## 📝 Maintenance & Contribution
This `README.md` is updated regularly alongside repository commits to reflect current features, directory structures, and code architecture changes.
