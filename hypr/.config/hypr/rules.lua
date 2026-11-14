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

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name = "float-apps",
    match = { class = ".*([Ss]atty|swayimg|pavucontrol|blueman-manager|nm-connection-editor).*" },
    float = true,
})

hl.window_rule({
    name = "file-chooser-portal",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
    center = true,
    size = { 1000, 700 },
})

hl.window_rule({
    name = "file-chooser-dialogs",
    match = { title = "^(Open File|Open Files|Save File|Save As|Select a File|Select Folder|Open Folder|File Upload)$" },
    float = true,
    center = true,
    size = { 1000, 700 },
})

hl.window_rule({
    name = "pavucontrol-size",
    match = { class = "^(org\\.pulseaudio\\.)?pavucontrol$" },
    float = true,
    center = true,
    size = { 900, 650 },
})

hl.layer_rule({ name = "rofi-blur", match = { namespace = "^rofi$" }, blur = true })
hl.layer_rule({ name = "swaync-blur", match = { namespace = "^swaync" }, blur = true })
hl.layer_rule({ name = "wlogout-blur", match = { namespace = "^wlogout$" }, blur = true })
