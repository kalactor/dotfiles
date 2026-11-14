local vars = require("vars")

-- Tag an array of window matches.  With `field`, each entry is a plain string
-- matched against that field; otherwise each entry is already a match table.
local function tagged_rule(tag, matches, field)
    for _, match in ipairs(matches) do
        if field then
            match = { [field] = match }
        end
        hl.window_rule({ match = match, tag = "+" .. tag })
    end
end

-- Define a tag once.  Hyprland requires tag definitions to come after every
-- window that uses them.
local function create_tag(tag, rules)
    local rule = { match = { tag = tag } }
    for key, value in pairs(rules) do
        rule[key] = value
    end
    hl.window_rule(rule)
end

local opaque_tag          = "opaque"
local float_tag           = "float"
local float_50_60_tag     = "float_50_60"
local float_60_70_tag     = "float_60_70"
local float_70_80_tag     = "float_70_80"
local game_tag            = "game"
local xwl_popup_tag       = "xwl_popup"
local system_monitor_tag  = "system_monitor"
local communication_tag   = "communication"

-----------------------
---- Default rules ----
-----------------------

hl.window_rule({
    -- Ignore client maximize requests; Hyprland owns window layout.
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Center every floating window except Xwayland popups, which often position
-- themselves relative to their parent.
hl.window_rule({
    name = "center-floaters",
    match = { float = true, xwayland = false },
    center = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

-- Picture-in-picture: float, pin and keep the player's aspect ratio.  The
-- initial move keeps it from jumping before the PiP keybind resizes it.
hl.window_rule({
    name = "picture-in-picture",
    match = { title = "Picture(-| )in(-| )[Pp]icture" },
    move = "(monitor_w*0.98-window_w) (monitor_h*0.97-window_h)",
    pin = true,
    float = true,
    keep_aspect_ratio = true,
})

---------------------
---- Tagged rules ----
---------------------

-- Apps that should not be transparent.
tagged_rule(opaque_tag, {
    "mpv",
    "swayimg",
    "satty",
    "gimp",
    "krita",
    "inkscape",
    "darktable",
    "blender",
    "godot",
    "kdenlive",
    "shotcut",
    "obs",
}, "class")

-- Floating apps.
tagged_rule(float_tag, {
    "satty",
    "swayimg",
    "blueman-manager",
    "nm-connection-editor",
    "file-roller",
    "yad",
    "zenity",
}, "class")
tagged_rule(float_tag, {
    "File (Operation|Upload)( Progress)?",
    ".* Properties",
    'Rename ".*"',
}, "title")

-- Monitor-relative sized floaters.
tagged_rule(float_60_70_tag, {
    "(Select|Open)( a)? (File|Folder)(s)?",
    "Save As",
    "File Upload",
}, "title")
tagged_rule(float_60_70_tag, {
    "pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol",
    "xdg-desktop-portal-gtk",
}, "class")

tagged_rule(float_70_80_tag, {
    "org.gnome.Settings|gnome-control-center",
}, "class")

tagged_rule(float_50_60_tag, {
    "nwg-look",
    "system-config-printer",
}, "class")

-- Games get opaque windows, immediate tearing and no idle inhibition.
tagged_rule(game_tag, {
    "steam_app_[0-9]+",
    "steam_app_default",
    "gamescope",
}, "class")

-- Xwayland popups are tiny and should not inherit blur or shadows.
tagged_rule(xwl_popup_tag, {
    { xwayland = true, title = "win[0-9]+" },
    { xwayland = true, title = "", class = "", initial_title = "", initial_class = "" },
})

-- Special workspaces.
tagged_rule(system_monitor_tag, { "btop" }, "class")
tagged_rule(communication_tag, {
    "Telegram",
    "telegram",
    "org.telegram.desktop",
    "discord",
    "vesktop",
    "equibop",
    "whatsapp",
}, "class")

-------------------------
---- Tag definitions ----
-------------------------

create_tag(opaque_tag, { opaque = true })
create_tag(float_tag, { float = true })
create_tag(float_50_60_tag, { float = true, size = "(monitor_w*0.5) (monitor_h*0.6)", center = true })
create_tag(float_60_70_tag, { float = true, size = "(monitor_w*0.6) (monitor_h*0.7)", center = true })
create_tag(float_70_80_tag, { float = true, size = "(monitor_w*0.7) (monitor_h*0.8)", center = true })
create_tag(game_tag, { opaque = true, immediate = true, idle_inhibit = "always" })
create_tag(xwl_popup_tag, {
    no_dim = true,
    no_shadow = true,
    no_blur = true,
    opaque = true,
    rounding = math.min(10, vars.rounding),
})
create_tag(system_monitor_tag, { workspace = "special:sysmon" })
create_tag(communication_tag, { workspace = "special:communication" })

-------------------------
---- Workspace rules ----
-------------------------

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.single_window_gaps_out })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = vars.single_window_gaps_out })

---------------------
---- Layer rules ----
---------------------

hl.layer_rule({ name = "rofi-blur", match = { namespace = "^rofi$" }, blur = true })
hl.layer_rule({ name = "swaync-blur", match = { namespace = "^swaync" }, blur = true })
hl.layer_rule({ name = "wlogout-blur", match = { namespace = "^wlogout$" }, blur = true })
