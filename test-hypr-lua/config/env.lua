-- =============================================================================
-- 🌐 ENVIRONMENT VARIABLES (hl.env)
-- =============================================================================

-- Nvidia Driver Settings
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Cursor Sizes & Theme
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")

-- Qt & Desktop Theming (WhiteSur-dark icon theme via KDE integration, matching Niri)
hl.env("XDG_MENU_PREFIX", "plasma-")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_STYLE_OVERRIDE", "Darkly")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_LOGGING_RULES", "quickshell.dbus.properties=false")
