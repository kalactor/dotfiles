local primary = "DP-3"
local secondary = "HDMI-A-1"

hl.monitor({
    output   = primary,
    mode     = "1920x1080@165",
    position = "0x0",
    scale    = "auto",
    supports_wide_color = -1,
})

hl.monitor({
    output   = secondary,
    mode     = "preferred",
    position = "0x-1080",
    scale    = "auto",
})

-- Workspaces stay strictly numeric: 1-5 on DP-3, 6-10 on HDMI-A-1.
for workspace = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = primary,
        default = true,
    })
end

for workspace = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = secondary,
        default = true,
    })
end
