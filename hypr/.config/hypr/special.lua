-- Special workspaces that know which apps belong on them.

local vars = require("vars")

local function contains(actual, expected)
    if actual == nil then
        return false
    end
    return tostring(actual):find(tostring(expected), 1, true) ~= nil
end

local function window_matches(window, match)
    for key, expected in pairs(match) do
        if key == "workspace" then
            local name = window.workspace and window.workspace.name or ""
            if not contains(name, expected) then
                return false
            end
        else
            local actual = window[key]
            if actual == nil and key == "class" then
                actual = window.initial_class
            elseif actual == nil and key == "title" then
                actual = window.initial_title
            end
            if not contains(actual, expected) then
                return false
            end
        end
    end
    return true
end

local function find_windows(app)
    local found = {}
    for _, window in ipairs(hl.get_windows() or {}) do
        for _, match in ipairs(app.match or {}) do
            if window_matches(window, match) then
                found[#found + 1] = window
                break
            end
        end
    end
    return found
end

-- Launch missing apps, or move stray clients onto the target workspace.
local function place_apps(apps, name)
    local target = "special:" .. name

    for _, app in ipairs(apps or {}) do
        local found = find_windows(app)

        if #found == 0 then
            if app.command then
                hl.dispatch(hl.dsp.exec_cmd(app.command, { workspace = target }))
            end
        elseif app.move then
            for _, window in ipairs(found) do
                local current = window.workspace and window.workspace.name or ""
                if current ~= target then
                    hl.dispatch(hl.dsp.window.move({
                        window    = window,
                        workspace = target,
                        follow    = false,
                    }))
                end
            end
        end
    end
end

local function toggle(name)
    return function()
        local active = hl.get_active_special_workspace()
        local target = "special:" .. name
        local on_target = active and active.name == target

        -- Hide without launching anything: closing a workspace should never
        -- spawn the app you just closed.
        if on_target then
            hl.dispatch(hl.dsp.workspace.toggle_special(name))
            return
        end

        hl.dispatch(hl.dsp.focus({ workspace = target }))
        place_apps(vars.specials[name] and vars.specials[name].apps, name)
    end
end

-- Super+S: close whichever special workspace is open, otherwise show the
-- scratchpad.  This avoids leaving a special workspace stuck open.
local function toggle_any()
    local active = hl.get_active_special_workspace()
    if active then
        local name = active.name:gsub("^special:", "")
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
        return
    end

    hl.dispatch(hl.dsp.workspace.toggle_special(vars.scratchpad))
end

return {
    toggle     = toggle,
    toggle_any = toggle_any,
}
