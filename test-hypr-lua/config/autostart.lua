-- =============================================================================
-- 🚀 AUTOSTART PROCESSES (hl.on / hl.exec_cmd)
-- =============================================================================

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.on("hyprland.start", function()
    -- Sync environment & Icon/Cursor Theme
    hl.exec_cmd("systemctl --user import-environment XDG_MENU_PREFIX QT_QPA_PLATFORMTHEME QT_QPA_PLATFORM XDG_CURRENT_DESKTOP")
    hl.exec_cmd("kbuildsycoca6")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")

    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("~/.config/hypr/scripts/wallpapers/restore-wallpaper.sh")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("quickshell")
end)
