local vars = require("vars")

hl.config({
    general = {
        gaps_in = vars.gaps_in,
        gaps_out = vars.gaps_out,
        border_size = vars.border_size,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = vars.rounding,
        rounding_power = vars.rounding_power,

        -- Global transparency, shared by every application.
        active_opacity = vars.active_opacity,
        inactive_opacity = vars.inactive_opacity,

        -- Kept deliberately light for the GTX 1660 at 165 Hz.
        shadow = {
            enabled = vars.shadow_enabled,
            range = vars.shadow_range,
            render_power = vars.shadow_render_power,
            color = vars.shadow_color,
        },
        blur = {
            enabled = vars.blur_enabled,
            size = vars.blur_size,
            passes = vars.blur_passes,
            vibrancy = vars.blur_vibrancy,
            ignore_opacity = vars.blur_ignore_opacity,
        },
    },

    animations = {
        enabled = true,
    },

    binds = {
        scroll_event_delay = 0,
    },

    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        close_special_on_empty = true,
        on_focus_under_fullscreen = 2,
        allow_session_lock_restore = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        focus_on_activate = true,
    },
})

-- Wallust-generated palette; safe on the first run before it exists.
pcall(require, "colors")

hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",       enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",       enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",      enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 4.1,  spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn",       enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",      enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",         enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",       enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 1.5,  bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut",enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",   enabled = true, speed = 7,    bezier = "quick" })

hl.config({
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    scrolling = { fullscreen_on_one_column = true },
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true,
    },
})
