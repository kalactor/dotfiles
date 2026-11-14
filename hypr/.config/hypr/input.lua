local vars = require("vars")
local special = require("special")

hl.config({
    input = {
        numlock_by_default = true,
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = vars.touchpad_natural_scroll,
            scroll_factor = vars.touchpad_scroll_factor,
            disable_while_typing = vars.touchpad_disable_typing,
        },
    },

    gestures = {
        workspace_swipe_distance                 = 700,
        workspace_swipe_cancel_ratio             = 0.15,
        workspace_swipe_min_speed_to_force       = 5,
        workspace_swipe_direction_lock           = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new               = true,
    },
})

hl.gesture({
    fingers = vars.workspace_swipe_fingers,
    direction = "horizontal",
    action = "workspace",
})

-- Three-finger up reveals the scratchpad; down toggles it.
hl.gesture({
    fingers = vars.gesture_fingers,
    direction = "up",
    action = "special",
    workspace_name = vars.scratchpad,
})

hl.gesture({
    fingers = vars.gesture_fingers,
    direction = "down",
    action = special.toggle(vars.scratchpad),
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
