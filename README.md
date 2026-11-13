# dotfiles

A Hyprland rice for Arch Linux: **SDDM**, **kitty**, **vim**, **Waybar**,
**SwayNC**, **rofi**, **wlogout**, **hyprlock**, **wallust**. No Quickshell.

One wallpaper change recolors the desktop:

```bash
wall set ~/Pictures/walls/<image>.jpg
```

## Layout

| Path | Contents |
|---|---|
| `hypr/.config/hypr/` | `hyprland.lua`, `hyprlock.conf`, `hyprpaper.conf` |
| `waybar/.config/waybar/` | bar config + CSS (imports generated `colors.css`) |
| `swaync/.config/swaync/` | notification daemon + CSS |
| `rofi/.config/rofi/` | launcher (imports generated `colors.rasi`) |
| `wlogout/.config/wlogout/` | power menu (imports generated `colors.css`) |
| `kitty/.config/kitty/` | terminal (includes generated `colors.conf`) |
| `vim/.vimrc` | vim + vim-plug + coc.nvim (generated colorscheme) |
| `wallust/.config/wallust/` | color engine config + templates |
| `bin/.local/bin/` | `wall`, `theme-apply`, `rice-*` helpers |
| `gtk/.config/gtk-{3,4}.0/` | GTK settings + generated `gtk.css` |
| `rice/.config/rice/hooks/` | optional `theme-set.d/` hooks |
| `system/` | **copies only** — system config, SDDM theme, package lists |

Generated files (`colors.css`, `colors.rasi`, `colors.lua`, `colors.conf`,
`hyprlock-colors.conf`, `gtk.css`, `wallust.vim`) are gitignored.

## Install / re-stow

```bash
cd ~/dotfiles
stow hypr waybar kitty swaync rofi wallust swayimg wlogout vim bash bin gtk rice
```

`system/` is deliberately not stowed; see `system/README.md`.

## Theme engine

`wall` sets the hyprpaper wallpaper, then `theme-apply` runs wallust and reloads:

| Target | File |
|---|---|
| Hyprland borders | `~/.config/hypr/colors.lua` |
| Waybar | `~/.config/waybar/colors.css` |
| SwayNC | `~/.config/swaync/colors.css` |
| rofi | `~/.config/rofi/colors.rasi` |
| kitty | `~/.config/kitty/colors.conf` |
| hyprlock | `~/.config/hypr/hyprlock-colors.conf` |
| GTK 3/4 | `~/.config/gtk-{3,4}.0/gtk.css` |
| vim | `~/.vim/colors/wallust.vim` |
| wlogout | `~/.config/wlogout/colors.css` |

Wallpaper binds:

| Keys | Action |
|---|---|
| `Super+F6` | next wallpaper |
| `Super+Shift+F6` | previous wallpaper |
| `Super+F7` | random wallpaper |
| `Super+F8` | pick with thumbnails |

Add a hook by dropping an executable in `~/.config/rice/hooks/theme-set.d/`.
It receives the image path as `$1`.

## Key bindings (selected)

| Keys | Action |
|---|---|
| `Super+Return` | kitty |
| `Super+A` | rofi launcher |
| `Super+N` / `Super+Shift+N` | notifications / DND |
| `Super+Shift+V` | clipboard history |
| `Super+Shift+C` | color picker |
| `Super+L` | lock (hyprlock) |
| `Super+Backspace` | power menu (wlogout) |
| `Super+Shift+F10` | night light |
| `Super+M` | hyprshutdown menu |
| `XF86Audio*` | volume via swayosd |
| `XF86MonBrightness*` | DP-3 brightness over DDC/CI |

Waybar runs **only on `DP-3`**. Workspaces 1–5 live there; 6–10 on `HDMI-A-1`.

## Health / restart

```bash
rice-doctor     # commands, services, generated files, Waybar outputs
rice-restart    # restart waybar + swaync + hyprpaper
```

## SDDM

The custom greeter theme is in `system/sddm/themes/rice/`. It needs `sudo` to
install; see **`system/sddm/README.md`** for install, preview, rollback and
wallpaper-update commands.

## Recovery

If a lock screen crashes:

```bash
hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'
```

If Hyprland misbehaves, switch to a TTY (`Ctrl+Alt+F3`), log in, fix or revert
`~/dotfiles`, then `hyprctl reload`. Every phase is committed; use
`git log --oneline` and `git tag` to return to a known-good state.
