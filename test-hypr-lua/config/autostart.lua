-- =============================================================================
-- 🚀 AUTOSTART PROCESSES (hl.on / hl.exec_cmd)
-- =============================================================================

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("~/.config/hypr/scripts/wallpapers/restore-wallpaper.sh")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("quickshell")
end)
