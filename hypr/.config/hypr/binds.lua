local vars       = require("vars")
local special    = require("special")
local window     = require("window")
local workspaces = require("workspaces")

local mainMod = vars.workspace_mod
local terminal = vars.terminal
local fileManager = vars.file_manager
local menu = vars.launcher

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
bind(mainMod .. " + C", hl.dsp.exec_cmd(vars.browser), "Browser: Chrome")
bind(mainMod .. " + Backspace", hl.dsp.exec_cmd("pkill wlogout || wlogout"), "Power menu")
bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"), "Lock session")
bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"), "Exit Hyprland")
bind(mainMod .. " + F1", hl.dsp.exec_cmd("$HOME/.local/bin/rice-keybinds"), "Keybind cheatsheet")
bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("$HOME/.local/bin/rice-calculator"), "Calculator")
bind(mainMod .. " + CTRL + E", hl.dsp.exec_cmd("$HOME/.local/bin/rice-emoji"), "Emoji picker")
bind(mainMod .. " + SHIFT + R", hl.dsp.reload_config(), "Reload Hyprland config")

-- Window management
bind(mainMod .. " + Q", hl.dsp.window.close(), "Close window")
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(mainMod .. " + P", hl.dsp.window.pseudo(), "Toggle pseudotiling")
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), "Toggle split")
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Toggle fullscreen")
bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "Toggle maximized")
bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin(), "Toggle pinned window")
bind(mainMod .. " + Tab", hl.dsp.window.cycle_next(), "Next window")
bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }), "Previous window")

-- Window groups (tabbed containers).
bind(mainMod .. " + G", hl.dsp.group.toggle(), "Toggle window group")
bind(mainMod .. " + CTRL + G", hl.dsp.group.lock(), "Lock or unlock window group")
bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ out_of_group = true }), "Move window out of group")
bind(mainMod .. " + bracketleft", hl.dsp.group.prev(), "Previous window in group")
bind(mainMod .. " + bracketright", hl.dsp.group.next(), "Next window in group")

-- Reveal a terminal hidden by window swallowing.
bind(mainMod .. " + CTRL + W", hl.dsp.window.toggle_swallow(), "Reveal swallowed windows")

-- Relative resizing (10% steps, repeat while held).
bind(mainMod .. " + Minus", window.resize_active_window(-10, 0), "Decrease window width", { repeating = true })
bind(mainMod .. " + Equal", window.resize_active_window(10, 0), "Increase window width", { repeating = true })
bind(mainMod .. " + SHIFT + Minus", window.resize_active_window(0, -10), "Decrease window height", { repeating = true })
bind(mainMod .. " + SHIFT + Equal", window.resize_active_window(0, 10), "Increase window height", { repeating = true })

-- Arrow-key resizing in finer 5% steps.
bind(mainMod .. " + SHIFT + left", window.resize_active_window(-5, 0), "Resize window narrower", { repeating = true })
bind(mainMod .. " + SHIFT + right", window.resize_active_window(5, 0), "Resize window wider", { repeating = true })
bind(mainMod .. " + SHIFT + up", window.resize_active_window(0, -5), "Resize window shorter", { repeating = true })
bind(mainMod .. " + SHIFT + down", window.resize_active_window(0, 5), "Resize window taller", { repeating = true })

-- Swap or move the focused window relative to its neighbours.
for _, direction in ipairs({ "left", "right", "up", "down" }) do
    bind(mainMod .. " + CTRL + SHIFT + " .. direction, hl.dsp.window.swap({ direction = direction }), "Swap window " .. direction)
    bind(mainMod .. " + ALT + SHIFT + " .. direction, hl.dsp.window.move({ direction = direction }), "Move window " .. direction)
end
bind(mainMod .. " + CTRL + ALT + left", hl.dsp.window.move({ monitor = "l" }), "Move window to monitor left")
bind(mainMod .. " + CTRL + ALT + right", hl.dsp.window.move({ monitor = "r" }), "Move window to monitor right")

bind("CTRL + SUPER + Backslash", hl.dsp.window.center(), "Center window")
bind("CTRL + SUPER + ALT + Backslash", window.normalize, "Resize to 55x70% and center")
bind(mainMod .. " + ALT + Backslash", window.picture_in_picture, "Picture-in-picture mode")

-- Special workspaces
bind(mainMod .. " + S", special.toggle_any, "Toggle scratchpad or close special workspace")
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:" .. vars.scratchpad }), "Move window to scratchpad")
bind("CTRL + SHIFT + Escape", special.toggle("sysmon"), "System monitor workspace")
bind(mainMod .. " + D", special.toggle("communication"), "Communication workspace")

-- Notifications, utilities and capture
bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"), "Notification center")
bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -d"), "Toggle do not disturb")
bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd("swaync-client -C"), "Clear notifications")
bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("$HOME/.local/bin/rice-clipboard"), "Clipboard history")
bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), "Color picker")
bind(mainMod .. " + SHIFT + F10", hl.dsp.exec_cmd("$HOME/.local/bin/rice-nightlight"), "Toggle night light")
bind(mainMod .. " + F9", hl.dsp.exec_cmd("$HOME/.local/bin/gsr-toggle"), "Toggle screen recording")
-- VoiceFlow dictation: hold to record, release to transcribe.
bind("CTRL + SHIFT + F12", hl.dsp.global("com.voiceflow.app:voiceflow-record"), "VoiceFlow: hold to dictate")

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

-- Screenshots and OCR share one helper so the keybinds stay short.
bind("Print", hl.dsp.exec_cmd("$HOME/.local/bin/rice-screenshot region"), "Screenshot: region")
bind("SHIFT + Print", hl.dsp.exec_cmd("$HOME/.local/bin/rice-screenshot full"), "Screenshot: all screens")
bind(mainMod .. " + Print", hl.dsp.exec_cmd("$HOME/.local/bin/rice-screenshot output"), "Screenshot: select output or region")
bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("$HOME/.local/bin/rice-screenshot window"), "Screenshot: select a window")
-- X for "extract text"; O sits next to 0 and is easy to confuse with
-- workspace 10, whose move-and-follow bind is SUPER+SHIFT+0.
bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("$HOME/.local/bin/rice-screenshot ocr"), "OCR: copy text from a region")

-- Focus and numeric workspaces (10 maps to key 0).
bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), "Focus left")
bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), "Focus right")
bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), "Focus up")
bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), "Focus down")

-- Relative workspace navigation wraps inside the fixed 1-10 ring.
bind(mainMod .. " + CTRL + left", workspaces.focus_relative(-1), "Previous workspace (relative)")
bind(mainMod .. " + CTRL + right", workspaces.focus_relative(1), "Next workspace (relative)")

for workspace = 1, 10 do
    local key = workspace % 10
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }), "Workspace " .. workspace)
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }), "Move window to workspace " .. workspace)
    bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = workspace, follow = false }), "Move window silently to workspace " .. workspace)
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
