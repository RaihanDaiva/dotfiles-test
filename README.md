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
- **⚡ Extensible QuickSettings Architecture (`widgets/quickSetting/` & `QuickSettingsPopup.qml`):**
  - **Modular ControlPills & StyledSliders:** Dynamic URL resolving supporting multiple shape styles (**Android Material 3 16px** vs **macOS Capsule**). Switching styles updates all pills and sliders seamlessly.
  - Interactive Disconnect pill buttons (`#f38ba8`) for active Wi-Fi connections (`nmcli connection down`) and Bluetooth devices (`bluetoothctl disconnect`).
  - **Saved Network Auto-Connect:** Clicking "Connect" on previously saved Wi-Fi networks connects instantly using saved NetworkManager credentials without requiring re-entering passwords.
- **🎵 Frosted Blurred Album Art Media Popup with CustomSlider (`MediaPopup.qml`):**
  - Modular media popup architecture located in `components/popups/mediaPopup/` supporting dynamic layout switching (**Classic** 310×485px & **Minimalist** 370×155px compact view).
  - Integrates standalone `CustomSlider` for smooth interactive audio playback progress seeking.
  - Features 1:1 cover art, seek bar, playback controls, and atmospheric frosted blurred album art background (`FastBlur` radius 40, `OpacityMask` radius 18, and translucent dark overlay).
  - **Dynamic Theme & Opacity Fallback:** Automatically resolves background tint using `Theme.bgDark` in both Light and Dark modes. When cover art blur is disabled, outer frosted overlay hides completely to respect global popup opacity settings.
- **⚙️ Elements & Popup Customizer Window (`settingsPopup/SettingsPopup.qml` & `SettingsStore.qml`):**
  - **Standalone Draggable Window:** Floating overlay window with draggable header handle (`MouseArea`), smooth screen auto-centering (`Component.onCompleted`), and `WlrLayershell` overlay layer.
  - **Sidebar Navigation Panel:** Left-side navigation panel with category tabs (**Popups** `󰖯` and **Buttons** `󰓠`). Uses `StyledButton` for consistent UI navigation.
  - **Modular Category Page Architecture (`category/`):**
    - `PopupsCategory.qml`: Category page for popup opacity, corner radius, border width, cover art blur toggle, media player style, and QuickSettings pill shape selector.
    - `ButtonsCategory.qml`: Dedicated category page for button theme customization (**Solid Fill** vs **Glass Outlined**) with interactive live preview showcase and corner radius slider.
  - **Reusable SettingCard Container (`widgets/settings/SettingCard.qml`):** Abstracted setting row container handling titles, descriptions, and flexible control slots (`CustomSlider`, `StyledSwitch`, `StyledButton` group).
  - **Custom Styled UI Widgets (`widgets/`):**
    - `StyledSwitch`: 46×24px pill track switch toggle with smooth color and position animations.
    - `StyledButton` & `buttonStyle/`: Modular reusable button shell wrapper with dynamic style resolver (`ButtonStyleSolid.qml` and `ButtonStyleTranslucent.qml`).
    - `CustomSlider`: Standalone custom styled slider widget used across Settings Popup and Media Popup.
    - `ControlPill` & `StyledSlider`: QuickSettings widgets with dynamic $N+$ shape style loader (`widgets/quickSetting/`).
  - **Calendar Grid Integration (`CalendarPopup.qml`):** Refactored 7×6 calendar day grid cells to use `StyledButton`, automatically inheriting global button styles.
  - **Persistent JSON Configuration (`services/SettingsStore.qml`):** Automatically saves and loads all user preferences (`buttonStyle`, `buttonRadius`, `quickSettingsStyle`, `isDarkMode`, `popupOpacity`, `popupRadius`, `popupBorderWidth`, etc.) to `~/.config/quickshell/settings.json`.
- **🪟 Mutually Exclusive Popup Manager (`PopupManager.qml`):**
  - Centralized singleton (`PopupManager.qml`) integrated directly into `BasePopup.qml` (`onIsOpenChanged`).
  - Automatically closes any previously active dropdown popup whenever a new popup is opened, completely preventing popup stacking/overlapping.

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
    │       ├── CalendarPopup.qml   # Interactive monthly calendar using StyledButton day grid
    │       ├── sysStatsPopup/      # Performance Dashboard popup (CPU/GPU Load & Temp, Mem, Storage)
    │       ├── mediaPopup/         # 🎵 Floating detail card with 1:1 cover art, seek bar & playback controls
    │       │   ├── MediaPopup.qml  # Media popup shell wrapper with theme & opacity fallback
    │       │   └── mediaStyle/     # Layout style implementations (MediaStyleClassic.qml & MediaStyleMinimalist.qml)
    │       ├── settingsPopup/      # ⚙️ Elements & Popup Customizer floating window
    │       │   ├── SettingsPopup.qml # Standalone draggable window shell with sidebar navigation panel
    │       │   └── category/       # Modular settings category pages (PopupsCategory.qml & ButtonsCategory.qml)
    │       ├── QuickSettingsPopup.qml # Windows 11 style 3-tier sliding Control Center popup with Customizer gear button & StyledSwitch
    │       ├── NotificationCenterPopup.qml # Notification Center popup extending BasePopup with Clear All button
    │       ├── OsdPopup.qml        # Real-time OSD overlay card for Volume & Brightness (exclusionMode: Ignore)
    │       ├── NotificationPopup.qml # Multi-toast stacked notification popup extending PanelWindow with slide animations
    │       ├── PowerPopup.qml      # Power menu popup dropdown extending BasePopup
    │       ├── PowerMenuOverlay.qml # Fullscreen Power Menu Overlay with Morphing Circle-to-Pill buttons (Super + P)
    │       ├── AppLauncherPopup.qml # Application Launcher popup extending PanelWindow with bottom-center search bar (Alt + A)
    │       └── WallpaperPopup.qml  # Horizontal Wallpaper Selector Carousel popup extending PanelWindow (Alt + W)
    ├── services/
    │   ├── NotificationStore.qml   # Central Singleton tracking active notification list
    │   ├── SettingsStore.qml       # ⚙️ Central Singleton handling settings persistence to ~/.config/quickshell/settings.json
    │   └── PopupManager.qml        # Central Singleton enforcing mutually exclusive popup behavior
    ├── theme/
    │   ├── Theme.qml               # Clean Singleton storing pure font & color properties (bound to SettingsStore.isDarkMode)
    │   └── PywalService.qml        # Background service syncing Pywal colors to Theme.qml
    ├── widgets/
    │   ├── BasePopup.qml           # Reusable PanelWindow popup shell with SettingsStore opacity/radius/border bindings & z: 9999 border overlay
    │   ├── ControlPill.qml         # Forwarding wrapper delegating to widgets/quickSetting/ControlPill.qml
    │   ├── StyledSlider.qml        # Forwarding wrapper delegating to widgets/quickSetting/StyledSlider.qml
    │   ├── SettingCard.qml         # Forwarding wrapper delegating to widgets/settings/SettingCard.qml
    │   ├── CustomSlider.qml        # 🎚️ Standalone reusable custom styled slider widget
    │   ├── StyledSwitch.qml        # 🔘 Reusable Material 3 / Catppuccin 46×24px switch toggle widget
    │   ├── LargeClock.qml          # Minimalist 2-line desktop clock widget using Theme.fontMain
    │   ├── quickSetting/           # 🎛️ REUSABLE QUICKSETTINGS WIDGET FOLDER
    │   │   ├── ControlPill.qml     # Dynamic pill shell wrapper resolving pill styles
    │   │   ├── StyledSlider.qml    # Dynamic slider shell wrapper resolving slider styles
    │   │   ├── pillStyle/          # QuickSettings pill shape implementations (PillStyleAndroid.qml & PillStyleMacos.qml)
    │   │   └── sliderStyle/        # QuickSettings slider shape implementations (SliderStyleAndroid.qml & SliderStyleMacos.qml)
    │   ├── settings/               # 🃏 REUSABLE SETTINGS WIDGET FOLDER
    │   │   └── SettingCard.qml     # Reusable setting row container handling titles, descriptions, & control slots
    │   ├── styledButton/           # 🔘 REUSABLE STYLED BUTTON WIDGET FOLDER
    │   │   ├── StyledButton.qml    # Reusable button wrapper with dynamic style loader
    │   │   └── buttonStyle/        # Button style implementations (ButtonStyleSolid.qml & ButtonStyleTranslucent.qml)
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
