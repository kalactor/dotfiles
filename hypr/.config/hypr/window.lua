-- Window helpers used by the keybind module.

local function resize_by_screen(x_percent, y_percent)
    local monitor = hl.get_active_monitor()
    if not monitor or type(monitor.width) ~= "number" or type(monitor.height) ~= "number" then
        return nil
    end

    if x_percent == 0 and y_percent == 0 then
        return nil
    end

    local width  = x_percent and x_percent > 0 and math.floor(monitor.width * x_percent / 100) or monitor.width
    local height = y_percent and y_percent > 0 and math.floor(monitor.height * y_percent / 100) or monitor.height

    return { x = width, y = height, relative = false }
end

-- Return a closure so Hyprland re-reads the active window on every repeat.
local function resize_active_window(x_percent, y_percent)
    return function()
        local window = hl.get_active_window()
        if not window or not window.size then
            hl.dispatch(hl.dsp.no_op())
            return
        end

        local x = math.floor(window.size.x * (x_percent / 100))
        local y = math.floor(window.size.y * (y_percent / 100))
        hl.dispatch(hl.dsp.window.resize({ x = x, y = y, relative = true }))
    end
end

-- Size a picture-in-picture window to roughly a quarter of the monitor and
-- park it in the bottom-right corner.
local function move_actions(window)
    local monitor = hl.get_active_monitor()
    if not monitor or not monitor.width or not monitor.height or not window or not window.size then
        return nil
    end

    local scale          = monitor.scale or 1
    local monitor_width  = monitor.width / scale
    local monitor_height = monitor.height / scale
    local scale_factor   = (monitor_height / 4) / window.size.y

    local target_width  = window.size.x * scale_factor
    local target_height = window.size.y * scale_factor
    local x_resize      = math.floor(math.max(200, target_width))
    local y_resize      = math.floor(math.max(150, target_height))
    local offset        = math.min(monitor_width, monitor_height) * 0.03

    local move_x = math.floor(monitor.x + monitor_width - x_resize - offset)
    local move_y = math.floor(monitor.y + monitor_height - y_resize - offset)

    return {
        hl.dsp.window.resize({ x = x_resize, y = y_resize, window = window }),
        hl.dsp.window.move({ x = move_x, y = move_y, relative = false, window = window }),
        hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true", window = window }),
    }
end

local function normalize()
    local window = hl.get_active_window()
    if not window then
        return
    end

    -- Make the action work on tiled windows too.
    if not window.floating then
        hl.dispatch(hl.dsp.window.float({ action = "on", window = window }))
    end

    local size = resize_by_screen(55, 70)
    if size then
        size.window = window
        hl.dispatch(hl.dsp.window.resize(size))
    end
    hl.dispatch(hl.dsp.window.center({ window = window }))
end

local function picture_in_picture()
    local window = hl.get_active_window()
    if not window then
        return
    end

    local actions = move_actions(window) or {}
    if not window.floating then
        table.insert(actions, 1, hl.dsp.window.float())
    end
    table.insert(actions, hl.dsp.window.pin({ action = "on", window = "address:" .. window.address }))

    for _, action in ipairs(actions) do
        hl.dispatch(action)
    end
end

return {
    resize_by_screen     = resize_by_screen,
    resize_active_window = resize_active_window,
    normalize            = normalize,
    picture_in_picture    = picture_in_picture,
}
