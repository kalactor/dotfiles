-- Workspace helpers that respect the fixed 1-5 / 6-10 monitor split.
--
-- Relative navigation wraps inside each monitor's five-workspace set, so it
-- never yanks you across monitors: 5 -> 1 on DP-3 and 10 -> 6 on HDMI-A-1.
-- Special or named workspaces fall back to Hyprland's occupied-workspace
-- selectors.

local function relative_id(delta)
    local workspace = hl.get_active_workspace()
    if not workspace then
        return nil
    end

    local id = tonumber(workspace.id)
    if not id then
        return nil
    end

    local base
    if id >= 1 and id <= 5 then
        base = 1
    elseif id >= 6 and id <= 10 then
        base = 6
    else
        return nil
    end

    return base + ((id - base + delta) % 5)
end

local function focus_relative(delta)
    return function()
        local target = relative_id(delta)
        if target then
            hl.dispatch(hl.dsp.focus({ workspace = target }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = delta > 0 and "e+1" or "e-1" }))
        end
    end
end

return {
    relative_id    = relative_id,
    focus_relative = focus_relative,
}
