local vars = require("vars")

hl.env("XCURSOR_SIZE", tostring(vars.cursor_size))
hl.env("HYPRCURSOR_SIZE", tostring(vars.cursor_size))
hl.env("XCURSOR_THEME", vars.cursor_theme)

-- NVIDIA (nvidia-open, DRM modesetting enabled).
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GBM_BACKEND", "nvidia-drm")

-- Qt uses qt6ct for the platform theme and Kvantum for widgets.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
