-- =============================================================================
-- 🎨 LOOK AND FEEL & ANIMATIONS (hl.config / hl.animation / hl.curve)
-- =============================================================================

-- Dynamically load Pywal color scheme from current wallpaper cache if available
local active_border = { colors = { "rgb(33ccff)", "rgb(00ff99)" }, angle = 45 }
local inactive_border = "rgb(595959)"

local wal_sh_path = (os.getenv("HOME") or "/home/han") .. "/.cache/wal/colors.sh"
local wal_file = io.open(wal_sh_path, "r")
if wal_file then
    local color11, color14, color1
    for line in wal_file:lines() do
        local key, val = line:match("^([%w_]+)='%#?([%x]+)'")
        if key == "color11" then color11 = val end
        if key == "color14" then color14 = val end
        if key == "color1"  then color1  = val end
    end
    wal_file:close()

    if color11 and color14 then
        active_border = { colors = { "rgb(" .. color11 .. ")", "rgb(" .. color14 .. ")" }, angle = 45 }
    end
    if color1 then
        inactive_border = "rgb(" .. color1 .. ")"
    end
end

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
        col = {
            active_border   = active_border,
            inactive_border = inactive_border,
        },
    },

    decoration = {
        rounding       = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled   = true,
            size      = 3,
            passes    = 4,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- Animation curves
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

-- Animations
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })
