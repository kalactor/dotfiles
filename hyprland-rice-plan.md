# Hyprland on Arch: Full Customization Plan

> Goal: one clean, beautiful, fully themed desktop where **one wallpaper change recolors everything**, every script has a home, and nothing is forgotten.
> Written 2026-11-10; **system analysis updated 2026-11-12** for: Arch Linux (rolling) + Hyprland **0.57.2 (Lua config)** + NVIDIA GTX 1660 + two monitors (`HDMI-A-1`, `DP-3`).
> Locked choices: **SDDM** login manager, **kitty** terminal, **vim** editor, **no Quickshell**.

**Legend**
- `[x]` = done and confirmed working (verified in chat or by the 2026-11-12 read-only system analysis)
- `[~]` = partially done / works but needs cleanup
- `[ ]` = to do (if it says *(provided, verify)* the config exists, but it is not confirmed yet)
- Package names: check with `pacman -Ss <name>`; if not found, try the AUR (`paru -S` / `yay -S`).

> **Current status, 2026-11-14:** core rice, SDDM, wallust, sunrise/sunset,
> Dolphin/KDE/Kvantum, wlogout and Telegram are complete. The reliability,
> modularization and restoration milestones are now also implemented: failures
> propagate, `rice-doctor` has exit codes, `rice-resume` repairs Waybar after
> sleep, Hyprland is split into modules, and `./tests/smoke.sh` runs fixture
> tests plus a fresh-profile Stow restore. Rofi includes a live keybind sheet,
> calculator and emoji picker. `rice-contrast` now enforces readable text and
> ANSI colours against the composited terminal background while keeping
> terminal transparency. Workspaces remain strictly numeric (`1-10`).
> The system snapshot and research below are the historical starting point;
> phase checkboxes and section 11 are the current roadmap.

---

## 0. How to use this file

1. Work **phase by phase** (0 → 7). Tick boxes as you go. Commit to git after every ticked phase.
2. Don't install a whole dotfiles project on top of your system. **Read them, copy ideas and scripts** (section 1).
3. Every config you touch lives in the git repo from phase 0 (section 2), so nothing is lost and you can undo anything.

---

## System snapshot (read-only analysis, 2026-11-12)

> Everything in this section was checked with read-only commands. **No system changes were made.** This is the baseline the checklist below now reflects.

### Hardware, OS and session

| Item | Verified state |
|---|---|
| OS / kernel | Arch Linux rolling; Linux `7.2.15-arch1-1`; installed `linux` package is `7.2.15.arch1-1` (matches running kernel) |
| CPU / RAM / GPU | Intel i5-9400F (6 cores), 15.55 GiB RAM, NVIDIA GTX 1660 6 GB (`nvidia-open 615.78.08`), `nvidia_drm.modeset=Y`, `nvidia-smi` works |
| Disk / boot | ext4 on `/dev/nvme0n1p2`, 456 GiB total; systemd-boot; Secure Boot enabled |
| Packages | 1017 total; 123 explicitly installed native; 14 AUR (including `yay`, `wallust`, `wlogout`, `wttrbar`, `google-chrome`) |
| Login | **SDDM 0.21.0** enabled + active; X11 greeter (`Xorg`); baseline snapshot had no theme (the custom `rice` theme was installed later) |
| Session | Hyprland 0.57.2 Wayland session on tty1; `hyprctl configerrors` is clean; 72 described keybinds loaded |
| Monitors | `DP-3` 1920x1080@165 at `0x0` (primary/focused); `HDMI-A-1` 1920x1080@60 at `0x-1080`; Waybar reserves 38 px at the top of `DP-3` only |
| Running | waybar, swaync, hyprpaper, hypridle, nm-applet, hyprpolkitagent, xdg-desktop-portal-hyprland, swayosd-server, Telegram, PipeWire/WirePlumber, NetworkManager, Bluetooth, CUPS, gnome-keyring |
| Not running | `udiskie` (installed, not started), `hyprlock` (idle, expected) |

### Decisions locked in

- **SDDM** is the login manager. Hyprland session = `/usr/bin/start-hyprland`; UWSM is not installed and not used.
- **kitty** is the terminal (0.50.0, currently running).
- **vim** is the text and code editor (9.2.1178; already default for `text/plain` via `vim.desktop`; `~/.vim/vimrc` uses vim-plug + coc.nvim).
- **No Quickshell.** Stay on Waybar + SwayNC + rofi + wlogout + hyprlock/hypridle. Caelestia/end-4/ML4W Quickshell ideas are reference only.
- **Waybar runs only on `DP-3`.** `HDMI-A-1` gets no bar; `config.jsonc` keeps `"output": "DP-3"`.
- Keep and refactor the existing configs; do not install a whole upstream dotfiles project.

### Already working (verified)

- Hyprland Lua config loads with no errors; monitors are positioned correctly; numlock is on; float rules for Satty/swayimg/pavucontrol/Blueman work.
- Screenshots (grim + slurp + Satty), screen recording (gpu-screen-recorder + Waybar indicator), wallpaper script, Waybar, SwayNC, hyprpaper and hypridle are running.
- wallust generates 16 targets from one wallpaper: Waybar, SwayNC, Hyprland, hyprlock, kitty, rofi, GTK 3/4, vim, wlogout, starship, btop, cava, SDDM, swayimg, and machine-readable palette files. `rice-contrast` then enforces WCAG contrast against the composited terminal background and re-renders the semantic templates.
- Audio (PipeWire/WirePlumber), NetworkManager, Bluetooth, CUPS, zram swap, timezone/NTP and GNOME keyring PAM unlock work.
- vim is the default text editor; kitty is the terminal; SDDM successfully starts Hyprland.

### Findings that need attention

| # | Finding | Evidence / impact | Plan action |
|---|---|---|---|
| 1 | **Polkit agent and Hyprland portal fail at login** | **Resolved 2026-11-12:** both services active; autostart runs `dbus-update-activation-environment` + `reset-failed`/`start` after the socket exists | Done |
| 2 | **Waybar is Omarchy-derived** | **Resolved:** all `omarchy-*`/`$OMARCHY_PATH` refs removed; dead modules deleted; one clean bar on `DP-3` only | Done |
| 3 | **`wall` name collides** | **Resolved:** `~/.local/bin` first in `.zshenv`/`.bashrc`; `command -v wall` -> `~/.local/bin/wall`; keybinds and `swayimg` use absolute paths | Done |
| 4 | **hyprpaper rotates by itself** | **Resolved:** single-file path; `timeout`/`order = random` removed; `wall` calls `theme-apply` | Done |
| 5 | **Dead Lua rules** | **Resolved:** replaced with `hl.layer_rule` (rofi, swaync, wlogout blur) | Done |
| 6 | **`Super+M` exit is broken** | **Resolved:** bound to `hyprshutdown` | Done |
| 7 | **Keybind map differs from the old plan** | **Resolved:** lock `Super+L`, power `Super+Backspace`, DND `Super+Shift+N`, clipboard `Super+Shift+V`, picker `Super+Shift+C` | Done |
| 8 | **Theming was only partial** | **Resolved:** wallust + `theme-apply` now cover shell, apps, Qt/KDE, SDDM, swayimg and Telegram | Done |
| 9 | **Semantic red is dynamic** | **Resolved:** status colours now come from contrast-safe ANSI slots; UI chrome uses `accent`/`accent_alt` instead of raw ANSI black | Done |
| 10 | **No dotfiles safety net** | **Resolved 2026-11-12:** `~/dotfiles` is a git repo; configs are stowed; package lists and `system/etc/` copies saved | Phase 0 done |
| 11 | **Missing utilities** | **Mostly resolved:** `cliphist`, `hyprpicker`, `hyprsunset`, `swayosd`, `ddcutil`, `qt6ct`, `kvantum`, `papirus-icon-theme`, `noto-fonts-cjk`, `hyprshutdown`, `fzf`, `zoxide`, `eza`, `bat`, `btop`, `cava`, `nwg-look` installed. Still optional: `waybar-module-pacman-updates` | Optional polish |
| 12 | **SDDM was unthemed** | **Resolved 2026-11-13:** custom `rice` theme installed and palette/wallpaper synchronized | Done |
| 13 | **GTK/Qt/fonts are not unified** | **Resolved:** Adwaita + Papirus light/dark variants + Inter; gsettings and `settings.ini` set; Qt uses qt6ct + generated Kvantum `WallustFlat`; kitty uses JetBrainsMono | Done |
| 14 | **Workspace/monitor rules are incomplete** | **Resolved:** 1-5 -> `DP-3`, 6-10 -> `HDMI-A-1`; `DP-3` runs 1920x1080@165 | Done |
| 15 | **Idle/suspend behavior needs a decision** | hypridle locks at 5 min, DPMS off at 5.5 min, suspends at 30 min; NVIDIA suspend/resume units are disabled | Decide desktop suspend; enable NVIDIA services if keeping it |
| 16 | **Some configs were missing** | **Resolved:** `user-dirs.dirs`, `.vimrc`, generated `starship.toml`, `mpv.conf`, `chrome-flags.conf` and the modular Hyprland config all exist | Done |
| 17 | **SwayNC CSS import is suspect** | **Resolved:** `@import "colors.css";` fixed; dedicated template defines every var; buttons/switches themed | Done |
| 18 | **swayimg `w` does not recolor** | **Resolved:** `init.lua` calls `$HOME/.local/bin/wall set <path>` | Done |
| 19 | **Light/dark palettes had poor contrast** | **Resolved 2026-11-14:** `rice-contrast` enforces 7:1 text, 4.5:1 ANSI, 3:1 borders against the composited terminal background; semantic roles replace ANSI black surfaces while kitty transparency stays on | Done |

### Missing packages relevant to this plan

`cliphist`, `hyprpicker`, `hyprsunset`, `swayosd`, `ddcutil`, `qt6ct`, `kvantum`, `nwg-look`, `papirus-icon-theme`, `noto-fonts-cjk`, `fzf`, `zoxide`, `eza`, `bat`, `btop`, `cava`, `hyprshutdown`, `waybar-module-pacman-updates`, `flatpak`, `weston`, `timeshift`/`snapper`/`restic`/`borg`/`rsync`, `reflector`, `pacman-contrib`, `ufw`.

Installed but currently unused/not running: `udiskie`, `hyprlauncher`, `wlogout` (used by the `Super+Backspace` bind), `wttrbar` (used by Waybar weather).

---

## 1. Research: what the top setups do (and what we copy)

| Project | What it is | Theming engine | How it separates "theirs" from "yours" | Steal this |
|---|---|---|---|---|
| **HyDE** (HyDE-Project/HyDE, ~9.5k stars) | Arch-focused, modular, XDG-compliant Hyprland environment | "Wallbash" dynamic colors + installable themes (themepatcher) for Waybar, Rofi, wallpapers | Core scripts are kept apart from your dotfiles so updates are safer. Replaced configs are backed up to `~/.config/cfg_backups` | Core-vs-user split, restore list (`Scripts/restore_cfg.psv`), theme packages |
| **Omarchy** (basecamp/omarchy, DHH) | Opinionated Arch + Hyprland distro | `colors.toml` (24 colors) per theme, **templates** generate configs for terminal, btop, mako, hyprlock, hyprland, waybar, walker, vscode, browser | Read-only defaults in `~/.local/share/omarchy/`, your changes in `~/.config/`. Themes in `~/.config/omarchy/themes/<name>/`. A `current/theme` symlink. **Hooks** in `~/.config/omarchy/hooks/` (`theme-set`, `font-set`, `post-update`) | One color file + templates, hook directory, `omarchy <group> <action>` command style, `refresh-*` / `restart-*` helper scripts |
| **JaKooLit Hyprland-Dots** | Big "feature-rich" dots with install/upgrade scripts (`copy.sh`, `upgrade.sh`, `release.sh`) | **wallust** → Waybar, Rofi, Kitty, SwayNC, hyprlock | `~/.config/hypr/configs/` (shipped), `UserConfigs/` and `UserScripts/` (yours, kept on upgrade); backups before copy | User* folders, many Waybar styles, wallpaper-picker flow. *Note: the Hyprland wiki lists it under "notable, but outdated"* |
| **end-4 / illogical-impulse** (~16.5k stars) | Mostly a custom graphical shell built on **Quickshell** (bar, sidebars, overview, AI) | Material You colors from the wallpaper | "Not a system setup script": it only ships the shell and configs | Wallpaper → full palette, overview, keybind cheat sheet. *It warns that Hyprland 0.57 (Lua) needs care; we are not using Quickshell* |
| **ML4W** (mylinuxforwork/dotfiles, ~4.9k stars) | Beginner-friendly full desktop with GUI settings app | Matugen / wallpaper-based variants | `custom.conf` for personal overrides; "variation" files in `hypr/conf/*` chosen from the settings app | Variation files + one personal override file. Docs site and welcome app |
| Bonus: **Caelestia** | Quickshell shell with its own CLI (**not using**) | `caelestia scheme set -n dynamic`, `caelestia wallpaper` | `~/.config/caelestia/shell.json`, `hypr-user.conf`, per-monitor config | A CLI for wallpaper + scheme, per-monitor options; reference only |

The Hyprland wiki's own "preconfigured setups" page currently lists: Omarchy, ML4W, end_4, HyDE, Dank Linux, fufexan, coffebar.

### The 8 patterns every good setup shares
1. **One color source → templates → every app** (wallust / colors.toml / matugen).
2. **One "apply theme" command** that regenerates colors and reloads everything.
3. **Defaults vs user overrides are separated** (so updates never destroy your edits).
4. **Hooks/extension points** so you can add a new app without editing the core script.
5. **A CLI for daily actions** (`theme set`, `wallpaper`, `power`, `screenshot`).
6. **Backups + git** for configs; restore lists.
7. **Docs and a keybind cheat sheet** inside the system.
8. **A health check / refresh command** to repair broken configs.

### Decisions for *our* setup (locked 2026-11-12)
- Keep **Waybar + SwayNC + rofi + hyprpaper + wlogout** (already working). **No Quickshell** — Caelestia/end-4/ML4W Quickshell ideas are reference only.
- **SDDM** is the login manager; Hyprland starts via `/usr/bin/start-hyprland` (UWSM not installed/not used).
- **kitty** is the terminal; **vim** is the text and code editor.
- **wallust** is the single color engine. Matugen is the alternative if you want Material You style colors.
- Config is **modular Lua** (`require`), scripts live in `~/.local/bin`, generated files are never edited by hand.
- A `theme-apply` script + a hooks folder (inspired by Omarchy) is the one place that recolors everything.
- Dotfiles in a **git repo managed with GNU Stow**.
- **The current config is a hybrid**: Omarchy-derived Waybar modules, Caelestia-flavoured kitty, Catppuccin rofi/swayimg. Refactor it instead of reinstalling.

> ⚠ Many of these dotfile projects are mid-migration to the Hyprland 0.57 Lua config (end-4 shows a warning for it, Omarchy Mac 4.0 moved to Lua). Their *ideas* are safe to copy, their raw `.conf` files are not. Our current Waybar config is already an Omarchy hybrid; clean it instead of copying more.

---

## 2. Where everything lives (the layout rules)

```
~/dotfiles/                         # git repo, managed with GNU Stow (one folder per app)
├── hypr/.config/hypr/              # -> ~/.config/hypr/
├── waybar/.config/waybar/
├── swaync/.config/swaync/
├── rofi/.config/rofi/
├── kitty/.config/kitty/            # kitty.conf + generated colors include
├── vim/.vimrc + vim/.vim/          # vim + vim-plug + coc.nvim
├── wallust/.config/wallust/        # wallust.toml + templates/
├── rice/.config/rice/              # our own settings + hooks (theme-set.d/)
├── swayimg/.config/swayimg/
├── gtk/.config/gtk-3.0/  ...       # gtk-3.0, gtk-4.0, qt6ct, Kvantum
├── bin/.local/bin/                 # -> ~/.local/bin/  (ALL custom scripts)
├── pkglists/                       # pacman -Qqen / -Qqem output
└── README.md                       # your own notes + keybind cheat sheet
```

> SDDM is system-level: its theme lives in `/usr/share/sddm/themes/<name>/` and its config in `/etc/sddm.conf.d/`. Keep a copy/notes in the repo, but do not stow it into `$HOME`.

```
~/.config/hypr/
├── hyprland.lua        # tiny: only require(...) lines
├── env.lua             # hl.env(): NVIDIA, cursor, Qt
├── monitors.lua        # hl.monitor() + workspace -> monitor rules
├── input.lua           # keyboard, mouse, numlock
├── look.lua            # general, decoration, animations, misc
├── colors.lua          # GENERATED by wallust (never edit)
├── rules.lua           # window, workspace and layer rules
├── binds.lua           # every keybind (one table, see section 6)
├── autostart.lua       # hl.on("hyprland.start", ...)
├── hyprlock.conf       # lock screen (uses generated colors)
├── hypridle.conf       # idle behavior
└── hyprpaper.conf      # wallpaper daemon
```

`hyprland.lua` skeleton (each `require` runs in its own scope, so an error in one module does not stop the others):
```lua
require("env")
require("monitors")
require("input")
pcall(require, "colors")   -- generated; may not exist on first run
require("look")
require("rules")
require("binds")
require("autostart")
```

| What | Where | Rule |
|---|---|---|
| Your scripts / commands | `~/.local/bin/` | Executable, on `PATH`, named by purpose (`rice-wall`, `theme-apply`, `rice-doctor`, `rec-toggle`); avoid names like `wall` that collide with system binaries |
| App configs | `~/.config/<app>/` | One folder per app, stowed from `~/dotfiles` |
| Our own settings and hooks | `~/.config/rice/` | `hooks/theme-set.d/*.sh` run after every theme change |
| Wallust templates | `~/.config/wallust/templates/` | One template per app |
| **Generated** files | next to each app (`colors.css`, `colors.lua`, ...) | Listed in `.gitignore`. Never edit by hand |
| Wallpapers | `~/Pictures/walls/` | Sub-folders are fine (`dark/`, `light/`, `anime/`) |
| Screenshots / recordings | `~/Pictures/Screenshots/`, `~/Videos/` | Temp files go to `/tmp` |
| Caches | `~/.cache/` | Safe to delete |
| Secrets | **not in git** | Keyrings, SSH keys, browser profiles |
| SDDM theme / greeter | `/usr/share/sddm/themes/<name>/`, `/etc/sddm.conf.d/` | System-level, not stowed; back up config and keep a note in the repo |

---

## 3. Phased checklist

### Phase 0: Foundations and safety
- [x] Arch Linux installed, Hyprland installed (Hyprland 0.57.2)
- [x] NVIDIA driver and DRM modesetting configured (`nvidia-open 615.78.08`, `nvidia_drm.modeset=Y`, `nvidia-smi` works)
- [x] System updated: running kernel `7.2.15-arch1-1` matches installed `linux 7.2.15.arch1-1` (verify with `pacman -Syu` before the next phase)
- [x] AUR helper installed (`yay 13.1.0`; `paru` not installed)
- [x] `git` + `stow` installed; `~/dotfiles` initialized as a git repo (branch `main`, 3 commits)
- [x] `~/dotfiles` initialized with `git init` and first commit
- [x] `~/.local/bin` moved **before** `/usr/bin` in `~/.zshenv`/`~/.bashrc`; `command -v wall` now resolves to `~/.local/bin/wall` (collision fixed)
- [x] Existing configs moved into `~/dotfiles` and stowed: `hypr`, `waybar`, `kitty`, `swaync`, `rofi`, `wallust`, `swayimg`, `wlogout`, `vim`, `bash`, `zsh`, `bin` (custom scripts)
- [x] `.gitignore` for generated files (`colors.css`, `colors.lua`, `colors.rasi`, caches) and secrets
- [x] Package lists saved: `pkglists/native.txt` (123) and `pkglists/aur.txt` (14)
- [ ] Optional pacman hook that refreshes the package lists after every install/remove
- [x] Snapshots/backups: **skipped by decision (2026-11-12)** — home PC, no external disk; git covers the rice
- [x] Mirror maintenance (`reflector.timer`) and cache cleaning (`paccache.timer`) — both installed, enabled and active
- [x] System config copies kept in `system/etc/` (`fstab`, `mkinitcpio.conf`, `pacman.conf`, `mirrorlist`, `locale.conf`, `vconsole.conf`)
- [x] Nerd Font installed (`ttf-jetbrains-mono-nerd` + `ttf-cascadia-code-nerd`)
- [x] Fonts: `noto-fonts`, `noto-fonts-emoji`, `noto-fonts-cjk`, `inter-font` installed
- [x] Timezone, locale and NTP correct (`Asia/Kolkata`, `en_IN.UTF-8`, NTP active)
- [x] `zram-generator` active (4 GiB zram swap)
- [ ] Optional firewall (`ufw` missing; `nftables`/`iptables` installed but inactive)

### Phase 1: Hyprland core (Lua)
- [x] Hyprland running on the Lua config (`hyprland.lua`, 0.57.2)
- [x] Config split into modules (`env`, `monitors`, `input`, `look`, `rules`, `binds`, `autostart`)
- [x] Lua autocomplete: `~/.config/hypr/.luarc.json` points to `/usr/share/hypr/stubs` with `globals: ["hl"]`
- [x] How Hyprland starts decided: **SDDM** -> `/usr/bin/start-hyprland` (UWSM not installed; `hyprland-uwsm.desktop` unused)
- [x] Environment: `XCURSOR_SIZE`/`HYPRCURSOR_SIZE`/`XCURSOR_THEME` set; NVIDIA (`LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME`, `NVD_BACKEND`, `GBM_BACKEND`) and Qt (`QT_QPA_PLATFORMTHEME=qt6ct`, `QT_STYLE_OVERRIDE=kvantum`) vars added
- [x] Monitors: `DP-3` 1920x1080@165 at `0x0`, `HDMI-A-1` at `0x-1080`; workspace rules 1-5 -> `DP-3`, 6-10 -> `HDMI-A-1`
- [x] Input: `numlock_by_default = true`; keyboard layout `us`
- [ ] Optional Hindi layout + switch key
- [x] Autostart: dbus activation env, polkit/portal reset+start, clipboard watchers, swayosd-server, nm-applet, waybar, swaync, hyprpaper, Telegram, hypridle
- [x] `dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE` runs at `hyprland.start`
- [x] Float rule for utility windows (`satty`, `swayimg`, `pavucontrol`, `blueman-manager`, `nm-connection-editor`); text editor not included
- [~] Window rules: suppress-maximize, XWayland fix, hyprland-run, float apps; no per-app opacity/workspace/no-blur/no-shadow
- [x] Layer rules: replaced the dead globals with `hl.layer_rule` (rofi, swaync, wlogout blur)
- [x] Keybind module: `binds.lua`; every bind includes a description consumed live by `rice-keybinds`; workspace bindings stay numeric
- [x] Safety habit: `hyprctl configerrors` clean after each change; known-good tags created
- [x] `known-good` git tags of the config

### Phase 2: Session plumbing (things that must just work)
- [x] Portals: `xdg-desktop-portal-hyprland` + `xdg-desktop-portal-gtk` active; autostart resets failed units after the Hyprland socket exists
- [x] Polkit agent: `hyprpolkitagent` active; autostart runs `reset-failed` + `start`
- [x] Keyring: `gnome-keyring` running; SDDM PAM log says "unlocked login keyring"; `seahorse` installed
- [x] Audio: PipeWire + WirePlumber running, `pavucontrol`, `pamixer`
- [x] Bluetooth: `bluez`, `bluez-utils`, `blueman` installed; service active (blueman applet not running; Waybar module works)
- [x] Network: NetworkManager active, `nm-applet` running, Waybar `network` module
- [x] Power profiles daemon installed (`powerprofilesctl get` -> `performance`)
- [x] Idle: `hypridle` running (lock 5 min, DPMS off 5.5 min, suspend 30 min)
- [x] Lock: `hyprlock` configured with wallust colors and visually tested; recover with `hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'`
- [x] Monitor brightness: `ddcutil` installed; `rice-brightness` controls DP-3 over DDC/CI (HDMI-A-1 is not DDC-capable)
- [x] Clipboard history: `cliphist` installed; `wl-paste` watchers autostart; `Super+Shift+V` opens `rice-clipboard`
- [x] `wl-clipboard` installed
- [~] Removable drives: `udisks2` installed; `udiskie` installed but **not running**
- [~] File manager extras: **Dolphin** (not Thunar) + `dolphin-plugins`, `gvfs`, `kio-extras`, `ark` installed; `tumbler`/`thunar-volman` not needed
- [x] XDG user dirs + default apps: `xdg-user-dirs` installed and configured; `mimeapps.list` sets Chrome, vim, swayimg, mpv
- [x] Printing: CUPS active + enabled (if needed)
- [x] Desktop suspend/resume repair: `hypridle` runs `rice-resume`, restoring the palette/wallpaper and checking Waybar's `DP-3` layer; optional NVIDIA driver suspend services remain a separate system decision
- [x] Autostart order check: dbus env + `reset-failed`/`start` for portals and polkit now run after Hyprland is up

### Phase 3: Desktop shell components
**Bar: Waybar**
- [x] Waybar running with the pulseaudio module (muted state styled)
- [x] Omarchy leftovers removed (2026-11-12): dead `custom/voxtype`, `custom/idle-indicator`, `custom/notification-silencing-indicator`, `custom/screenrecording-indicator` and unused `custom/update` deleted; `battery`/`backlight` dropped (desktop); `custom/updatespacman` replaced by `custom/updates` using `checkupdates`; separators renamed to `custom/sep` / `custom/sep-dot`; no `omarchy` or `$OMARCHY_PATH` references remain
- [x] **Waybar only on `DP-3`** (locked): `config.jsonc` has `"output": "DP-3"`; do not run a bar on `HDMI-A-1`
- [x] `colors.css` import and `@define-color`; status modules use semantic `@danger`/`@warning`/`@success`/`@info`, chrome uses `@accent`/`@accent_alt`
- [x] Waybar start/reload handled by `theme-apply` (`SIGUSR2`) and `rice-resume` (layer recreation when needed)

**Notifications: SwayNC**
- [x] SwayNC is the notification daemon (running)
- [x] `config.json` + `style.css` + `Super+N` toggle; widgets: title, DND, mpris, notifications
- [x] DND keybind (`Super+Shift+N` -> `swaync-client -d`)
- [x] `colors.css` generated from a dedicated template; `@import "colors.css";` fixed; hardcoded palette replaced with generated vars; panel pinned to DP-3

**Launcher and menus: rofi**
- [x] rofi installed; `Super+A` opens `rofi -show drun`
- [x] App launcher imports generated `colors.rasi`; opens on the focused monitor (`monitor: "-1"`)
- [x] Wallpaper picker with thumbnails (`wall pick`)
- [~] Power menu: **wlogout** is installed and bound to `Super+Backspace`; the planned rofi `power-menu` is not implemented (keep wlogout or switch)
- [x] Clipboard picker (`Super+Shift+V` -> `rice-clipboard`)
- [x] Calculator mode (`Super+Ctrl+C`, qalc) and emoji mode (`Super+Ctrl+E`)
- [x] Live keybind cheat sheet in rofi (`Super+F1`, reads `hyprctl binds -j`)

**Wallpaper**
- [x] hyprpaper running; `wall` script supports next / prev / random / set / pick
- [x] hyprpaper `path` set to one file; self-rotation (`timeout`, `order = random`) removed
- [ ] Optional timed rotation via `wall random` (hyprpaper no longer rotates independently)
- [~] Wallpaper collection in `~/Pictures/walls/` (20 files, flat; no mood subfolders)

**Capture and tools**
- [x] Screenshots: grim + slurp + satty (region, full, monitor, window)
- [x] Screen recording: gpu-screen-recorder with Waybar indicator (`custom/recorder`) and toggle bind
- [x] Floating swayimg / satty windows
- [x] swayimg `init.lua`; `w` calls `wall set`, so the wallpaper and the whole theme update
- [x] Color picker: `hyprpicker` installed; `Super+Shift+C` copies the hex
- [ ] Optional: freeze screen while selecting (`wayfreeze` missing)
- [x] Night light: `hyprsunset` installed; `Super+Shift+F10` toggles `rice-nightlight`

**OSD and extras**
- [x] On-screen display: `swayosd` installed; volume/mic keys use `swayosd-client` (brightness stays on DDC)
- [ ] Optional dock (`nwg-dock-hyprland`)
- [x] Optional hot reload helper: `rice-restart` installed

### Phase 4: Theming engine (color *every* aspect)
**Engine**
- [x] `wallust` installed (3.5.2, AUR)
- [x] Templates: 16 targets — shell, UI, editor, terminal, image viewer, login, TUI and machine-readable palette files
- [x] `~/.config/wallust/wallust.toml` has 16 targets
- [x] `theme-apply` created and **`wall` calls it** (absolute path, works with Hyprland's PATH)
- [x] Hooks folder `~/.config/rice/hooks/theme-set.d/` created and stowed
- [x] First run: `wallust run <image>` has generated every target
- [x] Contrast stage: `rice-contrast` enforces 7:1 text, 4.5:1 ANSI, 3:1 borders against the composited terminal background and re-renders semantic templates
- [x] Semantic palette: `surface`, `surface_alt`, `muted`, `border`, `accent`, `accent_alt`, `danger`, `success`, `warning`, `info`, `link`
- [x] ANSI roles preserved with `wallust --palette ansidark16 --colorspace lchansi`; ANSI 0/7/15 verified as a 7:1 black/white pair
- [x] `rice-contrast --check` covered by `tests/test_contrast.py` and `rice-doctor`
- [x] swayimg `w` key calls `wall set <path>` so it recolors too
- [x] Templates/targets for Hyprland (`colors.lua`), rofi (`colors.rasi`), kitty, hyprlock, GTK 3/4, vim, wlogout, btop, cava

**Static (not wallpaper-driven) choices: decide once**
- [x] GTK base theme + dark mode: `Adwaita-dark`, `prefer-dark`, gsettings + `settings.ini`
- [x] Icon theme: `Papirus-Dark`
- [x] Cursor theme + size: Adwaita, size 24 (Hyprland + gsettings)
- [x] Qt apps: `qt6ct` + generated wallpaper-driven Kvantum `WallustFlat`; `QT_QPA_PLATFORMTHEME=qt6ct`
- [x] UI/monospace fonts: JetBrainsMono Nerd Font (kitty, Waybar, rofi, hyprlock), Inter (GTK), Noto CJK installed
- [x] Hyprland look: `border_size = 2`, gradient borders from wallust, rounding/gaps/blur/shadows/animations
- [~] Per-app opacity: only global active 0.90 / inactive 0.85; no per-app values
- [x] Terminal: **kitty** chosen and running (0.50.0, CaskaydiaCove NF, zsh)
- [x] Kitty colors from wallust (`include ~/.config/kitty/colors.conf`; verified with `kitty @ get-colors`)
- [x] Prompt (`starship`) generated by wallust; zsh uses starship + autosuggestions + syntax highlighting + zoxide + fzf + eza aliases
- [x] Browser: Chrome 157 installed/default; Wayland + keyring flags in `~/.config/chrome-flags.conf`
- [x] Editor: **vim** chosen and default for `text/plain`; `~/.vim/vimrc` has vim-plug + coc.nvim
- [x] Vim colorscheme from wallust; verified `:hi Normal` uses the generated palette
- [x] Login screen / greeter: **SDDM** theme built and previewed; install commands in `system/sddm/README.md` (sudo handoff)
- [ ] Boot splash (Plymouth not installed; systemd-boot)
- [x] Lock screen: `hyprlock` configured (blurred screenshot, JetBrainsMono) with generated colors and tested

### Phase 5: Apps and utilities
- [x] File manager: **Dolphin** installed/configured (dolphinrc, kiorc, ark, gvfs, dolphin-plugins); replace the old Thunar plan
- [x] Text editor: **vim** chosen and set as default for `text/plain`
- [x] Code editor: **vim** (+ coc.nvim)
- [~] PDF viewer: currently Chrome (default `application/pdf`); no dedicated Okular/Zathura
- [x] Media player: `mpv` configured (`gpu-next`, `hwdec=auto-safe`, high-quality profile, resume)
- [x] Archive tool (`ark`), image viewer (`swayimg`), screenshot annotator (Satty)
- [~] Password manager, office suite, torrent client, VPN as needed: seed4 VPN scripts installed; no password manager/office/torrent; optional
- [x] Flatpak decision: `flatpak` installed for applications that need it; portals are working

### Phase 6: Polish
- [x] Animations/blur/shadow: reviewed for GTX 1660 + 165 Hz; retained one-pass, size-3 blur and range-4 shadows to avoid unnecessary GPU work
- [x] Blur/shadow: lightweight settings preserved in modular `look.lua`
- [x] Special workspace / scratchpad (`Super+S`, `Super+Shift+S`)
- [x] Workspaces: strictly numeric 1-10; 1-5 on `DP-3`, 6-10 on `HDMI-A-1` (user preference locked)
- [ ] Monitor profiles for plugging/unplugging (`kanshi` not installed)
- [ ] Optional plugins via `hyprpm` (not used)
- [ ] Optional: sounds for notifications and volume
- [x] **No Quickshell** — decision locked; stay with Waybar/SwayNC/rofi/wlogout. Do not add Caelestia/end-4/ML4W Quickshell layers

### Phase 7: Maintenance and safety net
- [x] `rice-doctor` health-check script installed (commands, services, generated files, Waybar outputs, config errors)
- [ ] Weekly routine: read Arch news, update, `hyprctl configerrors`, reboot test
- [x] One git commit per change; `known-good` tags created
- [x] Restore test: `tests/stow-smoke.sh` restores all 20 Stow packages plus systemd into an isolated HOME and checks numeric workspaces
- [x] Keybind cheat sheet and checklist in `~/dotfiles/README.md`
- [x] Recovery notes: TTY access, `hyprctl reload`, `hl.clear_crashed_lockscreen()`, git rollback

---

## 4. Color coverage: "so we miss nothing"

Every row should end up driven by the wallpaper (✅ target) or deliberately fixed (📌).

| Aspect | How it gets its colors | Status |
|---|---|---|
| Hyprland borders, shadows | wallust template → `~/.config/hypr/colors.lua`, `require("colors")`, then `hyprctl reload` | [x] generated + reloaded |
| Waybar | template → `colors.css`, `@import "colors.css";` in `style.css` | [x] generated + imported |
| SwayNC | dedicated template → `~/.config/swaync/colors.css` + `swaync-client -rs` | [x] generated; import fixed; GTK buttons/switches themed |
| rofi | template → `colors.rasi`, `@import "colors.rasi"` in the theme | [x] generated; state variables mapped |
| wlogout / power menu | template → `wlogout/colors.css`, `@import "colors.css";` | [x] generated |
| hyprlock | template → `hyprlock-colors.conf` sourced by `hyprlock.conf` | [x] generated + tested |
| Terminal (**kitty**) | template → `~/.config/kitty/colors.conf`, `include` it; reload kitty (`SIGUSR1`) | [x] generated; ANSI and foreground contrast enforced against the composited background |
| Shell prompt (starship) | generated palette file or fixed palette | [x] wallust-generated `starship.toml` |
| btop / cava / fastfetch | template into their theme/config files | [x] btop + cava generated by wallust; fastfetch static |
| GTK 3 / 4 apps (Dolphin, ...) | template → `~/.config/gtk-3.0/gtk.css`, `gtk-4.0/gtk.css` | [x] generated + Adwaita-dark/Papirus; common settings apps restarted by `rice-gtk-reload` |
| Qt apps | `qt6ct` + wallpaper-driven `kde-theme` generator | [x] generated Kvantum WallustFlat + merged kdeglobals |
| swayimg | wallust template → `~/.config/swayimg/colors.lua`, loaded on next open | [x] generated; `w` calls `wall set` |
| Editor (**vim**) | generated vim colorscheme or a fixed theme | [x] generated wallust colorscheme |
| Browser | manual theme color / dark mode | [x] Chrome Wayland + keyring flags |
| Cursor and icons | fixed | [x] Adwaita cursor, Papirus-Dark |
| Fonts | fixed | [x] JetBrainsMono + Inter + Noto CJK |
| **SDDM login screen** | theme + wallpaper/colors | [x] custom `rice` theme configured; palette/wallpaper synced when writable |
| Plymouth / bootloader | fixed theme or wallpaper sync (optional) | [ ] Plymouth not installed; systemd-boot |
| Fixed semantic colors | `@red` for muted/errors stays red in every theme | [x] status colours use contrast-safe ANSI slots; UI surfaces use semantic `surface`/`muted`/`accent` roles |

Template idea for Hyprland (check wallust docs for the exact filters; `strip` removes the `#`):
```lua
-- ~/.config/wallust/templates/hypr-colors.lua
return {
  background = "{{background | strip}}",
  foreground = "{{foreground | strip}}",
  accent     = "{{color4 | strip}}",
  accent2    = "{{color5 | strip}}",
}
```
and in `look.lua`: `local ok, c = pcall(require, "colors")` then build `"rgba(" .. c.accent .. "ee)"` when `ok`.

---

## 5. Scripts and commands inventory

| Script (in `~/.local/bin/`) | Purpose | Status |
|---|---|---|
| `wall` | next / prev / random / set FILE / pick (rofi thumbnails) | [x] working; PATH puts `~/.local/bin` first; keybinds use `$HOME/.local/bin/wall`; calls `theme-apply` |
| `theme-apply` | wallust + reload everything + run hooks | [x] created; reloads Hyprland, kitty, SwayNC, hooks |
| `power-menu` | lock / logout / suspend / reboot / shutdown via rofi | [~] not needed now: **wlogout** is installed + bound to `Super+Backspace`; optional rofi version |
| `gsr-toggle`, `gsr-status` | screen recording toggle + Waybar indicator | [x] working |
| `rice-doctor` | health check | [x] installed and green |
| `rice-restart` | restart waybar + swaync + hyprpaper cleanly | [x] installed |
| `rice-clipboard` | rofi clipboard history (`cliphist`) | [x] installed |
| `keybinds` / `rice-keybinds` | live rofi cheat sheet from `hyprctl binds -j` | [x] working; descriptions registered in `binds.lua` |
| `rice-resume` | restore wallpaper/theme and repair Waybar after login/sleep | [x] working; used by `hypridle` |
| `rice-calculator` | rofi + qalc; copies result | [x] working; unit tested |
| `rice-emoji` | rofi emoji picker backed by tracked catalog | [x] working; copies selection |
| `screenshot-*` | currently inline in `binds.lua`; optionally move into scripts | [~] 4 binds work inline |

> Current `~/.local/bin`: the tracked scripts above plus `rice-mode`, `kde-theme`, `telegram-theme`, `dolphin-view-defaults`, `rice-brightness`, `rice-nightlight`, `rice-clipboard`, `rice-doctor`, `rice-restart`, `gsr-status`, `gsr-toggle`, `wlogout` covers the power menu. External personal integrations such as `seed4` are optional and not part of a fresh baseline install.

### `theme-apply` (the single "recolor everything" command)
```bash
#!/usr/bin/env bash
# ~/.local/bin/theme-apply : recolor the whole desktop from one image
img="${1:?usage: theme-apply /path/to/image}"
hooks="$HOME/.config/rice/hooks/theme-set.d"

wallust run "$img" >/dev/null 2>&1 || { notify-send "theme-apply" "wallust failed"; exit 1; }

pkill -SIGUSR2 waybar 2>/dev/null       # reload Waybar
swaync-client -rs >/dev/null 2>&1       # reload SwayNC css
pkill -USR1 -x kitty 2>/dev/null        # reload kitty (remove if you do not use kitty)
hyprctl reload >/dev/null 2>&1          # re-read colors.lua

# user hooks: every executable in the folder gets the image path as $1
if [ -d "$hooks" ]; then
  for h in "$hooks"/*; do [ -x "$h" ] && "$h" "$img"; done
fi
```
In `wall`, change `set_wall` to: `hyprctl hyprpaper wallpaper ",$1,$FIT"; theme-apply "$1"`.

> Implemented: `wall` calls `$HOME/.local/bin/theme-apply` (absolute, because Hyprland's PATH does not include `~/.local/bin`). `~/.zshenv`/`~/.bashrc` puts `~/.local/bin` first for interactive shells.

### `rice-doctor` (health check)
```bash
#!/usr/bin/env bash
# ~/.local/bin/rice-doctor : is everything installed, generated and running?
ok()  { printf '  \033[32m✔\033[0m %s\n' "$1"; }
bad() { printf '  \033[31m✘\033[0m %s\n' "$1"; }

echo "Commands:"
for c in hyprctl waybar swaync swaync-client rofi wlogout wallust hyprpaper hyprlock hypridle \
         sddm kitty vim grim slurp satty wl-copy cliphist gpu-screen-recorder swayimg jq notify-send \
         powerprofilesctl pamixer udiskie gnome-keyring-daemon hyprlauncher wttrbar; do
  command -v "$c" >/dev/null && ok "$c" || bad "$c missing"
done

echo "Generated color files:"
for f in ~/.config/waybar/colors.css ~/.config/swaync/colors.css ~/.config/hypr/colors.lua \
         ~/.config/rofi/colors.rasi ~/.config/kitty/colors.conf ~/.config/hypr/hyprlock-colors.conf; do
  [ -s "$f" ] && ok "$f" || bad "$f missing (run: theme-apply <image>)"
done

echo "Running:"
for p in waybar swaync hyprpaper hypridle; do
  pgrep -x "$p" >/dev/null && ok "$p running" || bad "$p not running"
done

echo "Hyprland config errors:"
hyprctl configerrors

echo "Failed user units:"
systemctl --user is-failed hyprpolkitagent xdg-desktop-portal-hyprland 2>/dev/null
```

---

## 6. Keybind map (actual as of 2026-11-12)

| Keys | Action | Defined in |
|---|---|---|
| `Print` | Screenshot: select region → clipboard (+ notification) | binds |
| `Shift+Print` | Screenshot: all screens → `~/Pictures/Screenshots` + clipboard | binds |
| `Super+Print` | Screenshot: select output/region (`slurp -o -r`) | binds |
| `Super+Shift+Print` | Screenshot: click a window | binds |
| `Super+F9` | Start/stop screen recording | binds |
| `Super+F6` / `Super+Shift+F6` | Next / previous wallpaper | binds |
| `Super+F7` | Random wallpaper | binds |
| `Super+F8` | Wallpaper picker | binds |
| `Super+Backspace` | Power menu (`wlogout`) | binds |
| `Super+L` | Lock screen | binds |
| `Super+N` | SwayNC panel | binds |
| `Super+T` | kitty | binds |
| `Super+E` | Dolphin | binds |
| `Super+A` | rofi app launcher | binds |
| `Super+C` | Google Chrome | binds |
| `Super+Q` | Close window | binds |
| `Super+M` | Exit Hyprland (`hyprshutdown`) | binds |
| `Super+V` / `Super+P` / `Super+J` | Float / pseudo / toggle split | binds |
| `Super+S` / `Super+Shift+S` | Scratchpad / move window to scratchpad | binds |
| `Super+arrows`, `Super+1..0`, `Super+Shift+1..0` | Focus, workspaces, move window | binds |
| `Super+scroll`, `Super+LMB/RMB` | Workspace scroll, drag/resize | binds |
| `XF86Audio*`, `XF86MonBrightness*` | Volume/mic/brightness/playerctl | binds |
| *(to add)* | Clipboard history, color picker, night light, keybind cheat sheet, DND | binds |
| `Super+Q`, `Super+R`, `Super+M` | **Emergency binds** Hyprland adds when the Lua config has a major error | built in |

> Power is `Super+Backspace` (wlogout), lock is `Super+L`, and DND is
> `Super+Shift+N`. `Super+F1` opens the live keybind sheet, `Super+Ctrl+C` the
> calculator, and `Super+Ctrl+E` the emoji picker. See `binds.lua` for the
> current source of truth; emergency binds only appear after a major Lua error.

---

## 7. Master package list (verify names with `pacman -Ss`, AUR if missing)

```text
# Status 2026-11-12: [I] = installed, [M] = missing / install when needed.
# Hyprland ecosystem
[I] hyprland hyprpaper hyprlock hypridle hyprpolkitagent hyprlauncher
[I] xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprcursor hyprland-qt-support
[M] hyprpicker hyprsunset hyprshutdown

# Login / session
[I] sddm

# Shell parts
[I] waybar swaync rofi wlogout wl-clipboard libnotify wttrbar
[M] swayosd cliphist

# Capture and media
[I] grim slurp satty gpu-screen-recorder mpv swayimg
[I] kitty vim

# Theming
[I] wallust
[M] nwg-look qt6ct kvantum papirus-icon-theme
# optional: matugen (Material You), hyprqt6engine

# System plumbing
[I] pipewire pipewire-pulse wireplumber pavucontrol pamixer
[I] networkmanager bluez bluez-utils blueman
[I] power-profiles-daemon brightnessctl
[M] ddcutil
[I] gnome-keyring seahorse udisks2 udiskie
[M] xdg-user-dirs
[I] xdg-utils jq cups

# File manager (Dolphin, not Thunar)
[I] dolphin dolphin-plugins kio-extras ark gvfs
[M] tumbler thunar thunar-volman thunar-archive-plugin  # not needed with Dolphin

# Fonts
[I] ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd noto-fonts noto-fonts-emoji inter-font
[M] noto-fonts-cjk

# Terminal toys (pick what you use)
[I] starship fastfetch
[M] fzf zoxide eza bat btop cava

# Dotfiles / maintenance
[I] git stow yay
[M] reflector pacman-contrib ufw timeshift snapper restic borg rsync
```

---

## 8. Dotfiles with Stow (quick start)

> Current state (2026-11-12): **done**. `~/dotfiles` is a git repo on branch `main`; the configs below are stowed and `~/.config/<app>` are symlinks into the repo. New packages are added with `stow <pkg>`.

```bash
mkdir -p ~/dotfiles && cd ~/dotfiles && git init
# example: move Waybar config into the repo and link it back
mkdir -p waybar/.config
mv ~/.config/waybar waybar/.config/waybar
stow waybar                      # creates ~/.config/waybar -> ~/dotfiles/waybar/.config/waybar
# same pattern for kitty and vim
mkdir -p kitty/.config && mv ~/.config/kitty kitty/.config/kitty && stow kitty
mkdir -p vim
[ -f ~/.vimrc ] && mv ~/.vimrc vim/.vimrc
[ -d ~/.vim ] && mv ~/.vim vim/.vim
stow vim
# scripts
mkdir -p bin/.local/bin && mv ~/.local/bin/wall bin/.local/bin/ && stow bin
git add -A && git commit -m "waybar + kitty + vim + scripts"
```
Add generated files and secrets to `.gitignore` before the first commit. If you keep the `wall` name, ensure `~/.local/bin` comes **before** `/usr/bin` in `PATH`; otherwise rename it to `rice-wall` (see section 5).

---

## 9. Study list: what to read in each project

| Project | Read this first |
|---|---|
| HyDE | `Scripts/` folder (install and restore logic, `restore_cfg.psv`), docs site, `hyde-themes` repo |
| Omarchy | `bin/` (the `omarchy-*` scripts), `default/hypr/`, `themes/tokyo-night/colors.toml`, hooks, the release notes |
| JaKooLit Hyprland-Dots | `config/hypr/scripts`, `UserScripts`, `UserConfigs`, wallust templates, wiki changelogs |
| end-4 dots-hyprland | `dots/`, `sdata/deps-info.md`, docs at ii.clsty.link |
| ML4W | `hypr/conf/*` variations, settings app repo (`dotfiles-settings`), docs site |
| Caelestia | *not using* (Quickshell). Skip; only the CLI/wallpaper ideas were relevant |
| SDDM themes | `sddm-astronaut-theme` or `sddm-sugar-candy` (AUR), theme `theme.conf`, `/etc/sddm.conf.d/` |
| awesome-hyprland | sections: Notifications, OSD, Screenshotting, Locking/Idle/Clipboard, Runners/Menus, "IPC plugins" (small scripts) |

---

## 10. Learning and source links

**Official docs**
- Hyprland wiki (start here for Lua config): https://wiki.hypr.land/Configuring/Start/
- Hypr ecosystem tools (hyprlock, hypridle, hyprpicker, hyprsunset, hyprpolkitagent, hyprcursor, ...): https://wiki.hypr.land/Hypr-Ecosystem/
- Preconfigured setups listed by the Hyprland wiki: https://wiki.hypr.land/getting-started/preconfigured-setups/
- Environment variables (NVIDIA, cursor, Qt, UWSM note): https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
- Workspace rules: https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
- Window rules: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
- Monitors: https://wiki.hypr.land/Configuring/Basics/Monitors/
- hyprpaper: https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/
- hyprshutdown: https://wiki.hypr.land/Hypr-Ecosystem/hyprshutdown/
- Why Lua (announcement): https://hypr.land/news/26_lua/

**Dotfile projects (read, don't blindly install)**
- HyDE: https://github.com/HyDE-Project/HyDE · docs https://hydeproject.pages.dev
- Omarchy: https://github.com/basecamp/omarchy
- JaKooLit Hyprland-Dots: https://github.com/JaKooLit/Hyprland-Dots
- end-4 dots-hyprland: https://github.com/end-4/dots-hyprland · https://ii.clsty.link
- ML4W: https://github.com/mylinuxforwork/dotfiles · https://mylinuxforwork.github.io/dotfiles/
- Caelestia shell: https://github.com/caelestia-dots/shell — **not using** (Quickshell)

**Tools**
- awesome-hyprland (the big list of tools and scripts): https://github.com/hyprland-community/awesome-hyprland
- wallust: https://codeberg.org/explosion-mental/wallust
- matugen: https://github.com/InioX/matugen
- Waybar wiki: https://github.com/Alexays/Waybar/wiki
- SwayNotificationCenter: https://github.com/ErikReider/SwayNotificationCenter
- rofi: https://github.com/davatorium/rofi/wiki
- swayimg: https://github.com/artemsen/swayimg
- Satty: https://github.com/Satty-org/Satty
- gpu-screen-recorder: https://git.dec05eba.com/gpu-screen-recorder/about/
- SDDM: https://wiki.archlinux.org/title/SDDM · themes: https://github.com/keyitdev/sddm-astronaut-theme
- kitty: https://sw.kovidgoyal.net/kitty/ · vim: https://www.vim.org/docs.php
- Quickshell: **not used** (decision locked 2026-11-12)

**Arch background**
- Hyprland on the Arch Wiki: https://wiki.archlinux.org/title/Hyprland
- GNOME Keyring (PAM unlock): https://wiki.archlinux.org/title/GNOME/Keyring
- XDG Base Directory: https://wiki.archlinux.org/title/XDG_Base_Directory
- GNU Stow: https://www.gnu.org/software/stow/
- chezmoi (alternative dotfile manager): https://www.chezmoi.io/

---

## 11. Current maintenance path

The original phased build is complete. Keep the rice healthy with small,
testable changes rather than installing another shell or upstream dotfiles
project:

1. Run `./tests/smoke.sh` after script/config changes; use
   `RICE_LIVE_CHECKS=1 ./tests/smoke.sh` for the live health gate too.
2. Keep wallpaper-driven generation non-destructive. KDE merging preserves
   unknown user settings; generated files stay gitignored.
3. After suspend/login, `rice-resume` must leave Waybar on `DP-3` only and the
   current numeric workspace assignments unchanged.
4. Add future targets through wallust/templates or a small helper invoked by
   `theme-apply`, with fixture coverage and a clear success/failure result.
   Run `rice-contrast --check` after palette/template changes; keep the
   contrast policy role-aware so transparency and ANSI semantics survive.
5. Optional ideas only when actually wanted: monitor hotplug profiles,
   removable-drive automounting (`udiskie`), timed wallpaper rotation, a
   dedicated PDF reader, and semantic-color refinements. Browser theming stays
   deferred; numeric workspaces and no Quickshell are locked decisions.
6. Commit tested milestones and create known-good tags after verification.
