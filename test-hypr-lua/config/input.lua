-- =============================================================================
-- ⌨️ INPUT, TOUCHPAD & GESTURES (hl.config / hl.gesture / hl.device)
-- =============================================================================

hl.config({
    input = {
        kb_layout   = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -1,
})
