# dotfiles

A Hyprland rice for Arch Linux: **SDDM**, **kitty**, **vim**, **Waybar**,
**SwayNC**, **rofi**, **wlogout**, **hyprlock**, **wallust**. No Quickshell.

One wallpaper change recolors the desktop, and light/dark mode follows the
sun:

```bash
wall set ~/Pictures/walls/light/<image>.jpg
rice-mode status
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
| `btop/.config/btop/` | resource monitor (generated `themes/wallust.theme`) |
| `cava/.config/cava/` | audio visualizer (generated `themes/wallust`) |
| `mpv/.config/mpv/` | mpv playback config |
| `chrome/.config/chrome-flags.conf` | Chrome Wayland/keyring flags |
| `vim/.vimrc` | vim + vim-plug + coc.nvim (generated colorscheme) |
| `fastfetch/.config/fastfetch/` | minimal kitty startup summary |
| `wallust/.config/wallust/` | color engine config + templates |
| `bin/.local/bin/` | `wall`, `theme-apply`, `rice-mode`, `rice-*` helpers |
| `gtk/.config/gtk-{3,4}.0/` | GTK settings + generated `gtk.css` |
| `rice/.config/rice/hooks/` | optional `theme-set.d/` hooks |
| `systemd/.config/systemd/user/` | `rice-sun.service` + `rice-sun.timer` |
| `system/` | **copies only** — system config, SDDM theme, package lists |

Generated files (`colors.css`, `colors.rasi`, `colors.lua`, `colors.conf`,
`hyprlock-colors.conf`, `gtk.css`, `wallust.vim`, btop/cava themes) are gitignored.

## Install / re-stow

```bash
cd ~/dotfiles
stow hypr waybar kitty swaync rofi wallust swayimg wlogout vim bash bin gtk rice mpv chrome btop cava fastfetch
mkdir -p ~/.config/systemd/user
stow --no-folding systemd
systemctl --user daemon-reload
systemctl --user enable --now rice-sun.timer
```

`system/` is deliberately not stowed; see `system/README.md`.

A minimal fastfetch summary is printed once per kitty window (the `.bashrc`
guard uses `KITTY_WINDOW_ID`, so nested shells stay quiet).

## Theme engine

`wall` sets the hyprpaper wallpaper, then `theme-apply` runs wallust with
`--palette light` or `--palette dark` and reloads:

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
| starship | `~/.config/starship.toml` |
| btop | `~/.config/btop/themes/wallust.theme` |
| cava | `~/.config/cava/themes/wallust` |
| SDDM | `~/.cache/rice/Colors.qml` → installed theme |
| mode marker | `~/.cache/rice/theme-mode` |

`wall` only lists wallpapers from the current mode directory
(`~/Pictures/walls/light` or `~/Pictures/walls/dark`). Choosing a wallpaper
from the other directory forces that mode; choosing one from the current
directory keeps automatic switching enabled.

btop reloads live on `SIGUSR2`; cava reloads when its config is touched; an
open vim reloads its colorscheme within two seconds. `theme-apply` sends all
three signals/updates for you. GTK apps cannot reload `gtk.css` in place, so
`theme-apply` restarts the common settings apps (`pavucontrol`,
`nm-connection-editor`, `blueman-manager`, `nwg-look`) automatically; set
`RICE_GTK_RESTART=0` to disable that. GTK theme, icon theme and colour scheme
are switched through `gsettings`; Qt uses `qt6ct` + Kvantum (`KvArc` for light,
`KvArcDark` for dark), and vim's `background` is set to match.

### What reloads automatically

| App | Behaviour |
|---|---|
| Hyprland, Waybar, SwayNC, kitty | live reload |
| btop | live reload via `SIGUSR2` |
| cava | live reload via `live-config` |
| vim | live reload within 2 s (timer + focus) |
| starship | next prompt |
| rofi, wlogout, hyprlock | next time they open |
| SDDM | next greeter start (after install) |
| GTK apps | gsettings theme/icon switch; common settings apps restart automatically, others on next open |
| Qt apps | next open (qt6ct + Kvantum) |
| Chrome | not themed by wallust; Chrome's own UI theme is separate |

hyprlock uses the current light/dark wallpaper as a blurred background and
adjusts its scrim and clock colour per mode, so the lock screen stays readable
in both palettes.

Wallpaper binds (always inside the current light/dark mode):

| Keys | Action |
|---|---|
| `Super+F6` | next wallpaper |
| `Super+Shift+F6` | previous wallpaper |
| `Super+F7` | random wallpaper |
| `Super+F8` | pick with thumbnails |

The chosen wallpaper is also symlinked to `~/.cache/rice/wallpaper`; hyprpaper
loads that path at login, so the selection survives a reboot.

Add a hook by dropping an executable in `~/.config/rice/hooks/theme-set.d/`.
It receives the image path as `$1` and the palette mode as `$RICE_MODE`.

## Automatic light/dark mode

`rice-mode` computes sunrise/sunset locally with the NOAA solar algorithm. No
network access or extra package is needed after the location is known. The
default location is `28.133528,76.7542707` (the same coordinates as the Waybar
weather module); change it with `rice-mode location LAT,LON` or
`rice-mode location auto`.

| Command | Effect |
|---|---|
| `rice-mode status` | mode, effective mode, sunrise/sunset, next transition, wallpaper |
| `rice-mode auto` | follow sunrise/sunset again |
| `rice-mode light` | force light mode and stop auto switching |
| `rice-mode dark` | force dark mode and stop auto switching |
| `rice-mode toggle` | switch to the opposite forced mode |
| `rice-mode location [LAT,LON\|auto]` | show or change the sun location |
| `rice-mode tick` | apply the current mode (timer entry point) |
| `rice-mode resume` | re-apply at login after hyprpaper starts |

`rice-sun.timer` runs `rice-mode tick` every five minutes. A manual
`light`/`dark`/`toggle` override is persistent until `rice-mode auto` is used
again. The Waybar sun/moon indicator shows the effective mode; left-click
toggles, right-click returns to auto.

Mode state lives in `~/.cache/rice/`: `mode`, `effective-mode`, `location`,
`wallpaper-light`, `wallpaper-dark`, and `theme-mode`.

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
| `Super+Ctrl+L` | force light mode |
| `Super+Ctrl+D` | force dark mode |
| `Super+Ctrl+A` | automatic light/dark mode |
| `Super+Ctrl+T` | toggle forced light/dark |
| `Super+M` | hyprshutdown menu |
| `XF86Audio*` | volume via swayosd |
| `XF86MonBrightness*` | DP-3 brightness over DDC/CI |

Waybar runs **only on `DP-3`**. Workspaces 1–5 live there; 6–10 on `HDMI-A-1`.

## Health / restart

```bash
rice-doctor                       # commands, services, generated files, mode state
rice-mode status                  # current mode + sunrise/sunset
systemctl --user list-timers rice-sun.timer
rice-restart                      # restart waybar + swaync + hyprpaper
rice-gtk-reload                   # restart running GTK settings apps after a palette change
```

## SDDM

The custom greeter theme is in `system/sddm/themes/rice/`. It needs `sudo` to
install; see **`system/sddm/README.md`** for install, preview, rollback and
wallpaper-update commands. Once installed with the documented `chown`, SDDM
follows the wallpaper and light/dark palette automatically.

## Recovery

If a lock screen crashes:

```bash
hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'
```

If Hyprland misbehaves, switch to a TTY (`Ctrl+Alt+F3`), log in, fix or revert
`~/dotfiles`, then `hyprctl reload`. Every phase is committed; use
`git log --oneline` and `git tag` to return to a known-good state.
