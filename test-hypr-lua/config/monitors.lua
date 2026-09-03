-- =============================================================================
-- 🖥️ MONITORS CONFIGURATION (hl.monitor)
-- =============================================================================

-- Laptop Screen (eDP-1)
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "1920x0",
    scale    = 1,
})

-- External Monitor (DP-1)
hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@165",
    position = "0x0",
    scale    = 1,
})

-- Fallback default
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
