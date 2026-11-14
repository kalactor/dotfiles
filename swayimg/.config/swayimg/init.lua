-- swayimg config: only overrides, defaults stay for everything else.
-- Needs swayimg >= 5.6  (check with: swayimg --version)

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------
swayimg.appid = "swayimg"            -- window class, used by the Hyprland float rule
swayimg.mode = "viewer"              -- viewer | gallery | slideshow
swayimg.antialiasing = true

-- include subfolders (your walls/vimwell folder)
swayimg.imagelist.recursive = true
swayimg.imagelist.order = "numeric"

-- Wallust palette (generated on every wallpaper change; fallback for first run).
local palette = {}
local palette_ok, loaded = pcall(dofile, os.getenv("HOME") .. "/.config/swayimg/colors.lua")
if palette_ok and type(loaded) == "table" then
  palette = loaded
end
local foreground = palette.foreground or 0xffcdd6f4
local background = palette.background or 0xff11111b
local surface = palette.surface or 0xff1e1e2e
local selection = palette.selection or 0xff313244
local accent = palette.accent or 0xff89b4fa

-- text overlay
swayimg.text.font = "JetBrainsMono Nerd Font"
swayimg.text.size = 16
swayimg.text.color = foreground

--------------------------------------------------------------------------------
-- Viewer
--------------------------------------------------------------------------------
swayimg.viewer.default_scale = "optimal"
swayimg.viewer.set_window_background(background)
swayimg.viewer.set_image_chessboard(20, surface, selection)

swayimg.viewer.text = {
  topleft    = { "{name}" },
  topright   = { "{list.index} / {list.total}" },
  bottomleft = { "{frame.width}x{frame.height}  |  {sizehr}  |  {scale}" },
}

--------------------------------------------------------------------------------
-- Gallery and slideshow
--------------------------------------------------------------------------------
swayimg.gallery.thumb_size = 220
swayimg.gallery.pstore = true                    -- cache thumbnails on disk
swayimg.gallery.window_color = background
swayimg.gallery.unselected_color = surface
swayimg.gallery.selected_color = selection
swayimg.gallery.border_color = accent

swayimg.slideshow.timeout = 8

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local function sh_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function run_ok(cmd)
  local ok = os.execute(cmd)
  return ok == true or ok == 0
end

local function set_wallpaper(img)
  if not img then return end
  -- `wall set` sets hyprpaper and runs theme-apply, so the whole rice recolors.
  os.execute("$HOME/.local/bin/wall set " .. sh_quote(img.path) .. " >/dev/null 2>&1 &")
  swayimg.text.status = "Wallpaper + theme set"
end

local function trash(get_image)
  local img = get_image()
  if not img then return end
  if run_ok("gio trash " .. sh_quote(img.path)) then
    swayimg.imagelist.remove(img.path)
    swayimg.text.status = "Moved to trash: " .. img.path
  else
    swayimg.text.status = "Trash failed (is gio installed?)"
  end
end

--------------------------------------------------------------------------------
-- Keys (added on top of the defaults)
--------------------------------------------------------------------------------
-- set as wallpaper (hyprpaper)
swayimg.viewer.on_key("w", function() set_wallpaper(swayimg.viewer.get_image()) end)
swayimg.gallery.on_key("w", function() set_wallpaper(swayimg.gallery.get_image()) end)

-- Delete = move the file to trash (not permanent)
swayimg.viewer.on_key("Delete", function() trash(swayimg.viewer.get_image) end)
swayimg.gallery.on_key("Delete", function() trash(swayimg.gallery.get_image) end)

-- copy image to clipboard
swayimg.viewer.on_key("Ctrl+c", function()
  local img = swayimg.viewer.get_image()
  if img then
    os.execute("wl-copy < " .. sh_quote(img.path) .. " &")
    swayimg.text.status = "Image copied"
  end
end)

-- navigation
swayimg.viewer.on_key("space", function() swayimg.viewer.open("next") end)
swayimg.viewer.on_key("r", function() swayimg.viewer.open("random") end)
swayimg.viewer.on_key("home", function() swayimg.viewer.open("first") end)
swayimg.viewer.on_key("end", function() swayimg.viewer.open("last") end)

-- zoom presets
swayimg.viewer.on_key("1", function() swayimg.viewer.set_fix_scale("real") end)
swayimg.viewer.on_key("2", function() swayimg.viewer.set_fix_scale("fit") end)
swayimg.viewer.on_key("3", function() swayimg.viewer.set_fix_scale("fill") end)

-- q quits (Escape still works)
swayimg.viewer.on_key("q", function() swayimg.exit() end)
swayimg.gallery.on_key("q", function() swayimg.exit() end)

-- Optional, if you float swayimg: open the window at the image's size
-- swayimg.viewer.on_image_change(function()
--   local image = swayimg.viewer.get_image()
--   if image then swayimg.set_window_size(image.width, image.height) end
-- end)
