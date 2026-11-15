local vars = require("vars")

hl.env("XCURSOR_SIZE", tostring(vars.cursor_size))
hl.env("HYPRCURSOR_SIZE", tostring(vars.cursor_size))
hl.env("XCURSOR_THEME", vars.cursor_theme)
hl.env("HYPRCURSOR_THEME", vars.cursor_theme)

-- Prefer native Wayland, with X11 as a fallback for older clients.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- NVIDIA (nvidia-open, DRM modesetting enabled).
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GBM_BACKEND", "nvidia-drm")

-- Qt uses qt6ct for the platform theme and Kvantum for widgets.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
