-- =============================================================================
-- 🎨 LOOK AND FEEL & ANIMATIONS (hl.config / hl.animation / hl.curve)
-- =============================================================================

-- Dynamically load Pywal color scheme from current wallpaper cache if available
local active_border = "rgb(8baa51)"
local inactive_border = "rgba(595959aa)"

local wal_sh_path = (os.getenv("HOME") or "/home/han") .. "/.cache/wal/colors.sh"
local wal_file = io.open(wal_sh_path, "r")
if wal_file then
    local color11
    for line in wal_file:lines() do
        local key, val = line:match("^([%w_]+)='%#?([%x]+)'")
        if key == "color11" then color11 = val end
    end
    wal_file:close()

    if color11 then
        active_border = "rgb(" .. color11 .. ")"
    end
end

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = {top = 0, right = 10, bottom = 10, left = 10},
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

-- =============================================================================
-- 🎬 ANIMATION CURVES & BEZIERS (hl.curve)
-- =============================================================================
hl.curve("wind",         { type = "bezier", points = { { 0.05, 1.0 }, { 0.1, 1.0 } } })
hl.curve("winIn",        { type = "bezier", points = { { 0.1, 1.1 },  { 0.1, 1.0 } } })
hl.curve("winOut",       { type = "bezier", points = { { 0.3, 0.0 },  { 0.1, 1.0 } } })
hl.curve("liner",        { type = "bezier", points = { { 1.0, 1.0 },  { 1.0, 1.0 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 },  { 0.75, 1.0 } } })

-- =============================================================================
-- 🎞️ ANIMATIONS (hl.animation)
-- =============================================================================
-- Windows
hl.animation({ leaf = "windows",     enabled = true, speed = 6,    bezier = "wind",         style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,    bezier = "winIn",        style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5,    bezier = "winOut",       style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,    bezier = "wind",         style = "slide" })

-- Borders
hl.animation({ leaf = "border",      enabled = true, speed = 1,    bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = false })

-- Layers (Popups, Overlays)
hl.animation({ leaf = "layers",      enabled = true, speed = 6,    bezier = "wind",         style = "popin 90%" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 6,    bezier = "winIn",        style = "popin 90%" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2,    bezier = "winOut",       style = "popin 90%" })

-- Workspaces
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5, bezier = "wind" })
hl.animation({ leaf = "specialWorkspace",  enabled = true, speed = 5, bezier = "wind",     style = "slidevert 15%" })

-- Fade
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3.03, bezier = "almostLinear" })
