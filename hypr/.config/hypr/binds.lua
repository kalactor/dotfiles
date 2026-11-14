local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "rofi -show drun"

-- One registration path keeps descriptions attached to the actual bindings.
-- `rice-keybinds` reads these through `hyprctl binds -j`, so help cannot drift.
local function bind(key, action, description, options)
    options = options or {}
    options.description = description
    return hl.bind(key, action, options)
end

-- Applications and menus
bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal), "Terminal: kitty")
bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), "Files: Dolphin")
bind(mainMod .. " + A", hl.dsp.exec_cmd(menu), "Application launcher")
bind(mainMod .. " + C", hl.dsp.exec_cmd("google-chrome-stable"), "Browser: Chrome")
bind(mainMod .. " + Backspace", hl.dsp.exec_cmd("pkill wlogout || wlogout"), "Power menu")
bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"), "Lock session")
bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"), "Exit Hyprland")
bind(mainMod .. " + F1", hl.dsp.exec_cmd("$HOME/.local/bin/rice-keybinds"), "Keybind cheatsheet")
bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("$HOME/.local/bin/rice-calculator"), "Calculator")
bind(mainMod .. " + CTRL + E", hl.dsp.exec_cmd("$HOME/.local/bin/rice-emoji"), "Emoji picker")

-- Window management
bind(mainMod .. " + Q", hl.dsp.window.close(), "Close window")
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(mainMod .. " + P", hl.dsp.window.pseudo(), "Toggle pseudotiling")
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), "Toggle split")
bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"), "Toggle scratchpad")
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), "Move window to scratchpad")

-- Notifications, utilities and capture
bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"), "Notification center")
bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -d"), "Toggle do not disturb")
bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("$HOME/.local/bin/rice-clipboard"), "Clipboard history")
bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), "Color picker")
bind(mainMod .. " + SHIFT + F10", hl.dsp.exec_cmd("$HOME/.local/bin/rice-nightlight"), "Toggle night light")
bind(mainMod .. " + F9", hl.dsp.exec_cmd("$HOME/.local/bin/gsr-toggle"), "Toggle screen recording")

-- Wallpaper selection always stays inside the effective light/dark directory.
bind("SUPER + F6", hl.dsp.exec_cmd("$HOME/.local/bin/wall next"), "Next wallpaper")
bind("SUPER + SHIFT + F6", hl.dsp.exec_cmd("$HOME/.local/bin/wall prev"), "Previous wallpaper")
bind("SUPER + F7", hl.dsp.exec_cmd("$HOME/.local/bin/wall random"), "Random wallpaper")
bind("SUPER + F8", hl.dsp.exec_cmd("$HOME/.local/bin/wall pick"), "Choose wallpaper")

-- Automatic and manual light/dark mode.
bind("SUPER + CTRL + L", hl.dsp.exec_cmd("$HOME/.local/bin/rice-mode light"), "Force light mode")
bind("SUPER + CTRL + D", hl.dsp.exec_cmd("$HOME/.local/bin/rice-mode dark"), "Force dark mode")
bind("SUPER + CTRL + A", hl.dsp.exec_cmd("$HOME/.local/bin/rice-mode auto"), "Automatic light/dark mode")
bind("SUPER + CTRL + T", hl.dsp.exec_cmd("$HOME/.local/bin/rice-mode toggle"), "Toggle forced light/dark mode")

bind("Print", hl.dsp.exec_cmd('mkdir -p ~/Pictures/Screenshots; f=/tmp/shot-$(date +%s).png; g=$(slurp) || exit; grim -g "$g" "$f" && wl-copy -t image/png < "$f" && [ "$(notify-send -i "$f" -A default="Open in Satty" "Screenshot copied" "Click to annotate")" = default ] && satty -f "$f" --copy-command wl-copy --early-exit -o "$HOME/Pictures/Screenshots/%Y%m%d_%H%M%S.png"'), "Screenshot: select region and annotate")
bind("SHIFT + Print", hl.dsp.exec_cmd('mkdir -p ~/Pictures/Screenshots; f=$HOME/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png; grim "$f" && wl-copy -t image/png < "$f" && [ "$(notify-send -i "$f" -A default="Open in Satty" "Screenshot saved" "$f")" = default ] && satty -f "$f" --copy-command wl-copy --early-exit -o "$HOME/Pictures/Screenshots/%Y%m%d_%H%M%S-edited.png"'), "Screenshot: all screens")
bind(mainMod .. " + Print", hl.dsp.exec_cmd('mkdir -p ~/Pictures/Screenshots; f=$HOME/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png; g=$(slurp -o -r) || exit; grim -g "$g" "$f" && wl-copy -t image/png < "$f" && [ "$(notify-send -i "$f" -A default="Open in Satty" "Screenshot saved" "$f")" = default ] && satty -f "$f" --copy-command wl-copy --early-exit -o "$HOME/Pictures/Screenshots/%Y%m%d_%H%M%S-edited.png"'), "Screenshot: select output or region")
bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd([[mkdir -p ~/Pictures/Screenshots; f=$HOME/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png; ws=$(hyprctl monitors -j | jq -c 'map(.activeWorkspace.id)'); g=$(hyprctl clients -j | jq -r --argjson ws "$ws" '.[] | select(.mapped and (.workspace.id as $w | $ws | index($w))) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp -r) || exit; grim -g "$g" "$f" && wl-copy -t image/png < "$f" && [ "$(notify-send -i "$f" -A default="Open in Satty" "Screenshot saved" "$f")" = default ] && satty -f "$f" --copy-command wl-copy --early-exit -o "$HOME/Pictures/Screenshots/%Y%m%d_%H%M%S-edited.png"]]), "Screenshot: select a window")

-- Focus and numeric workspaces (10 maps to key 0).
bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), "Focus left")
bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), "Focus right")
bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), "Focus up")
bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), "Focus down")

for workspace = 1, 10 do
    local key = workspace % 10
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }), "Workspace " .. workspace)
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }), "Move window to workspace " .. workspace)
end

bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next occupied workspace")
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous occupied workspace")
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "Drag window", { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- Audio, DDC brightness and media keys.
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), "Volume up", { locked = true, repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), "Volume down", { locked = true, repeating = true })
bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), "Mute output", { locked = true, repeating = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), "Mute microphone", { locked = true, repeating = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("$HOME/.local/bin/rice-brightness up"), "Brightness up", { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("$HOME/.local/bin/rice-brightness down"), "Brightness down", { locked = true, repeating = true })
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), "Next track", { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), "Play or pause", { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), "Play or pause", { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), "Previous track", { locked = true })
