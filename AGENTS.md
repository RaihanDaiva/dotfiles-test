# AGENTS.md

## What This Repo Is

Dotfiles for a Wayland desktop supporting **two compositors** (Hyprland & Niri) and **two Quickshell shell configs**:

| Directory | What | Tracked |
|-----------|------|---------|
| `test-hypr/` | Hyprland compositor config | Yes |
| `niri/` | Niri compositor config (modular KDL) | Yes |
| `quickshell/han-dots/` | Custom Quickshell shell (bar, popups, lockscreen, dock) | Yes |
| `quickshell/inir/` | iNiR shell — full desktop environment (37 modules, 75+ services, two panel families) | **No** (gitignored) |

`quickshell/inir/` and `quickshell/ii/` are in `.gitignore` but may be present locally. They contain the upstream iNiR project code; **do not modify or commit changes to those directories**.

## Two Shell Configs — Don't Confuse Them

- **`quickshell/han-dots/`**: Your custom shell. Entry point: `shell.qml`. Uses `services/`, `theme/`, `widgets/`, `components/`, `scripts/`. Simpler, focused on status bar + popups.
- **`quickshell/inir/`**: The full iNiR desktop shell. Entry point: `shell.qml` with `pragma ShellId inir`. Has `modules/` (37), `services/` (75+), two panel families (`ii` and `waffle`). Uses `GlobalStates.qml` for UI state, `Config` singleton for settings, `LazyLoader` for deferred panel loading.

When editing Quickshell code, confirm which shell you're in. They share no imports or components.

## Niri Config (Modular KDL)

`niri/config.d/` — numbered files control load order:
- `10` Input/cursor → `20` Layout/gaps → `30` Window rules → `40` Env vars → `50` Startup → `60` Animations → `70` Keybinds → `80` Layer rules → `90` User overrides

`90-user-extra.kdl` is your personal override layer. The `apply_wallpaper.sh` script dynamically patches it with pywal focus-ring gradients via `sed`.

Niri auto-reloads on file save — no manual restart needed.

## Hyprland Config (Modular Conf)

`test-hypr/hyprland.conf` sources: `autostart.conf`, `hyprcolors.conf`, `animations.conf`, `input.conf`, `keybinds.conf`, `windowrule.conf`, `layerrule.conf`.

Keybinds use `$mainMod = SUPER`. Quickshell integration via `quickshell ipc call <target> <action>`.

## Pywal Integration (Critical)

Both shells rely on pywal colors from `~/.cache/wal/colors.json`:

- **han-dots**: `theme/PywalService.qml` polls every 2s, maps colors to `Theme.qml`. `apply_wallpaper.sh` triggers pywal on wallpaper change.
- **inir**: `services/ThemeService.qml` + `services/MaterialThemeLoader.qml` handle theming.
- **Niri**: `apply_wallpaper.sh` patches `focus-ring` gradient in `90-user-extra.kdl`.
- **Hyprland**: `apply_wallpaper.sh` patches `hyprcolors.conf`.

If colors look wrong after wallpaper change, check that `wal` ran and the respective service picked up the new colors.

## Key Scripts

| Script | Purpose |
|--------|---------|
| `quickshell/han-dots/scripts/apply_wallpaper.sh` | Full wallpaper pipeline: symlinks cache, renders via awww/hyprpaper, runs pywal, updates Niri focus-ring + Hyprland borders, reloads cava |
| `quickshell/han-dots/scripts/restore-wallpaper.sh` | Boot-time wallpaper restore (awww + swaybg blurred backdrop + pywal) |
| `quickshell/han-dots/scripts/sys_info.sh` | System metrics (18 outputs for QML consumption) |
| `quickshell/han-dots/scripts/sys_event_monitor.sh` | Real-time PipeWire volume + backlight event stream |
| `quickshell/inir/scripts/inir` | iNiR CLI (4150 lines): `run`, `restart`, `doctor`, `logs`, `status`, IPC targets, theme management |
| `quickshell/inir/setup` | Installer/maintainer: `install`, `update`, `migrate`, `doctor`, `rollback` |

## iNiR Panel Families

The iNiR shell supports two visual families switchable at runtime via `quickshell ipc call panelFamily cycle`:

- **`ii`** (default): Horizontal bar, vertical bar, sidebars, overview, tiling overlay. Loads via `ShellIiPanels.qml`.
- **`waffle`**: Windows 11-inspired (start menu, action center, task view). Loads via `ShellWafflePanels.qml`.

Panel IDs are registered in `shell.qml` → `panelFamilies` property. Only the active family's QML is parsed at startup (saves ~135 file parses).

Three loader types control panel initialization:
- `PanelLoader` — immediate (first-frame visible)
- `DeferredPanelLoader` — async (after first frame, waits for `shellEntryReady` then `deferredPanelsReady`)
- `OnDemandPanelLoader` — interactive (open/close lifecycle, idle timer)

## Settings Persistence

- **han-dots**: `services/SettingsStore.qml` → `~/.config/quickshell/settings.json`. 19 properties (popupOpacity, isDarkMode, barStyle, dockMode, etc.). Boot guard prevents overwriting saved defaults.
- **inir**: `Config` singleton (in `modules/common/`) → `~/.config/quickshell/inir-config.json`. Extensive options tree.

## IPC Communication

Both shells use Quickshell IPC (`quickshell ipc call <target> <function>`). Common targets:

| Target | Actions |
|--------|---------|
| `applauncher` | `toggle`, `open`, `close` |
| `wallpaperselect` | `toggle`, `open`, `close` |
| `powermenu` | `toggle`, `open`, `close` |
| `settings` | `toggle`, `open` |
| `lockscreen` | `lock`, `toggle` |
| `bar` | `toggle`, `open`, `close` |
| `panelFamily` | `cycle`, `set` |

## Multi-Monitor

Both shells use `Variants { model: Quickshell.screens }` to instantiate per-monitor surfaces. Workspace IDs are offset per monitor:
- Main monitor (eDP-1): workspaces 1–5 (`baseWsId = 1`)
- Second monitor (DP-1): workspaces 6–10 (`baseWsId = 6`)

`ControlCenter.qml` restricts `eventMonitorProc` to `Quickshell.screens[0]` to avoid duplicate OSD popups on multi-monitor.

## Common Pitfalls

1. **Editing the wrong shell**: `quickshell/han-dots/` vs `quickshell/inir/` — they're independent codebases.
2. **Modifying gitignored files**: `quickshell/inir/` changes will be lost or cause git confusion.
3. **Missing pywal colors**: If `~/.cache/wal/colors.json` doesn't exist or is stale, Theme.qml falls back to Catppuccin defaults (not the user's wallpaper colors).
4. **Niri config not reloading**: If `sed` patches to `90-user-extra.kdl` leave malformed KDL, niri won't reload. Check syntax.
5. **Duplicate IPC handlers**: The iNiR shell moved IPC handlers to `shell.qml` root to avoid collisions during panel family switching. Don't add new handlers inside panel files.
6. **LazyLoader timing**: Adding services to the wrong initialization tier (immediate vs deferred) affects boot time. Tier 0 = startup-critical, Tier 3 = T+500ms, Tier 4 = T+1500ms.
7. **`quickshell/han-dots/ii/`** exists and is tracked but is NOT the same as `quickshell/inir/`. It appears to be a legacy/subset copy.
