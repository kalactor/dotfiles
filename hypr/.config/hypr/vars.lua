-- Central tunables for the Hyprland modules.
--
-- Personal overrides belong in ~/.config/hypr/user.lua (gitignored).  It must
-- return a table; its keys are merged over the defaults below.

local vars = {
    -- Applications
    terminal     = "kitty",
    file_manager = "dolphin",
    launcher     = "rofi -show drun",
    browser      = "google-chrome-stable",

    -- Gaps and borders
    gaps_in                = 4,
    gaps_out               = 8,
    single_window_gaps_out = 20,
    border_size            = 2,
    rounding               = 10,
    rounding_power         = 2,

    -- Opacity
    active_opacity   = 0.90,
    inactive_opacity = 0.85,

    -- Shadow
    shadow_enabled      = true,
    shadow_range        = 4,
    shadow_render_power = 3,
    shadow_color        = "0xee1a1a1a",

    -- Blur
    blur_enabled        = true,
    blur_size           = 3,
    blur_passes         = 1,
    blur_vibrancy       = 0.1696,
    blur_ignore_opacity = true,

    -- Cursor
    cursor_theme = "Adwaita",
    cursor_size  = 24,

    -- Touchpad and gestures
    touchpad_natural_scroll = false,
    touchpad_scroll_factor  = 1.0,
    touchpad_disable_typing = true,
    gesture_fingers         = 3,
    workspace_swipe_fingers = 3,

    -- Workspaces
    workspace_mod = "SUPER",
    scratchpad    = "magic",

    -- Special workspaces.  Each app can declare match rules, a launch command
    -- and whether an already-running client should be moved onto the space.
    specials = {
        sysmon = {
            apps = {
                {
                    match   = { { class = "btop" }, { initial_class = "btop" } },
                    command = "kitty --class btop -e btop",
                },
            },
        },
        communication = {
            apps = {
                {
                    match = {
                        { class = "Telegram" },
                        { class = "telegram" },
                        { class = "org.telegram.desktop" },
                        { initial_class = "Telegram" },
                        { initial_class = "org.telegram.desktop" },
                    },
                    command = "Telegram",
                    move    = true,
                },
                -- Move-only entries: the matching tag already places these on
                -- launch, but a stray client should follow the workspace too.
                {
                    match = {
                        { class = "discord" },
                        { class = "vesktop" },
                        { class = "equibop" },
                    },
                    move = true,
                },
                {
                    match = { { class = "whatsapp" } },
                    move  = true,
                },
            },
        },
    },
}

-- Optional user overrides.  dofile() keeps this out of Lua's module cache and
-- avoids colliding with a system module named "user".
local home = os.getenv("HOME")
if home then
    local ok, overrides = pcall(dofile, home .. "/.config/hypr/user.lua")
    if ok and type(overrides) == "table" then
        for key, value in pairs(overrides) do
            vars[key] = value
        end
    end
end

return vars
