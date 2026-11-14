hl.on("hyprland.start", function()
    -- Make the Wayland session visible before portals start.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")

    -- These may have failed before the Hyprland socket existed.
    hl.exec_cmd("systemctl --user reset-failed hyprpolkitagent xdg-desktop-portal-hyprland; systemctl --user start hyprpolkitagent xdg-desktop-portal-hyprland")

    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("wl-paste --primary --watch cliphist store")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")

    -- Give hyprpaper a socket, then restore wallpaper, palette and shell layers.
    hl.exec_cmd("sh -c 'sleep 2; exec $HOME/.local/bin/rice-resume'")
    hl.exec_cmd("Telegram")
end)
