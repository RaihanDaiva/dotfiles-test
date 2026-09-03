-- =============================================================================
-- 🪟 WINDOW RULES & LAYER RULES (hl.window_rule / hl.layer_rule)
-- =============================================================================

-- Window Rules
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class    = "^$",
        title    = "^$",
        xwayland = true,
        float    = true,
    },
    no_focus = true,
})

-- Layer Rules for Quickshell overlays
hl.layer_rule({
    name       = "quickshell-bar-blur",
    match      = { namespace = "^quickshell:bar$" },
    blur       = true,
    ignore_alpha = 1.0,
})

hl.layer_rule({
    name       = "quickshell-dock-blur",
    match      = { namespace = "^quickshell:dock$" },
    blur       = true,
    ignore_alpha = 1.0,
})

hl.layer_rule({
    name       = "quickshell-popup-blur",
    match      = { namespace = "^quickshell:popup$" },
    blur       = true,
    ignore_alpha = 1.0,
})
