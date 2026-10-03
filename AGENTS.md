# Repository Guidelines

## Project Structure

This repository contains Wayland desktop dotfiles for Niri, Hyprland, and Quickshell. `niri/config.d/` holds numbered KDL configuration modules; `test-hypr/` contains modular Hyprland configuration in `.conf` files; and `test-hypr-lua/` contains the native Lua configuration and its modules. The tracked custom Quickshell shell is `quickshell/han-dots/`, with QML components, widgets, theme services, and helper scripts. `quickshell/inir/` and `quickshell/ii/` are gitignored upstream/local trees: do not edit or commit them. `quickshell/han-dots/ii/` is tracked and distinct from those directories.

## Development and Validation

There is no repository-wide build or automated test suite. Validate relevant files with the project tools:

- `niri validate` checks Niri configuration syntax.
- `qmlformat -i path/to/File.qml` formats QML; `qmllint path/to/File.qml` checks it when needed.
- `hyprctl reload` reloads Hyprland configuration in a running session.
- Run shell scripts directly only when their required desktop utilities and environment are available.

For runtime development, link the relevant config under `~/.config/` as described in `README.md`, then launch the compositor or `quickshell` in a suitable Wayland session.

## Style and Configuration

Use PascalCase filenames for QML components and camelCase for QML ids, properties, and functions. Keep variant styling in style-specific components and shared behavior in their parent component. Follow the existing modular organization: numbered Niri KDL files define load order, `hyprland.conf` sources the Hyprland `.conf` modules, and `test-hypr-lua/hyprland.lua` loads Lua modules. Keep user-specific Niri overrides in `90-user-extra.kdl`. Preserve executable bits on shell scripts and follow neighboring files' indentation and formatting.

## Testing Changes

No test framework or coverage requirement is configured. Choose validation for the edited area: validate Niri syntax, format and lint changed QML, and inspect compositor behavior in a live session when practical. Wallpaper and theme changes depend on pywal output in `~/.cache/wal/colors.json`; verify both the relevant script and shell theme service when changing that flow.

## Commits and Pull Requests

Recent commits use Conventional Commit-style subjects such as `feat(niri): ...` and `fix(quickshell): ...`; use a concise type and relevant scope. Pull requests should summarize the user-visible effect, list affected configurations, include validation performed, and attach screenshots for visual changes. Call out compositor-specific behavior and any required local utilities.

## Configuration Safety

Confirm whether a change belongs to `quickshell/han-dots/`, `test-hypr/`, `test-hypr-lua/`, or `niri/` before editing. Both shells use pywal colors, so keep theme updates consistent with their existing services and wallpaper scripts. Niri reloads configuration when files change; check KDL syntax after edits to dynamically patched overrides.
