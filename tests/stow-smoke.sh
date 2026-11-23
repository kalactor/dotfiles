#!/usr/bin/env bash
# Verify all stow packages install into an isolated HOME without touching it.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP_BASE="${TMPDIR:-/tmp/opencode}"
mkdir -p "$TMP_BASE"
target=$(mktemp -d "$TMP_BASE/rice-stow.XXXXXXXX")
trap 'rm -rf "$target"' EXIT

packages=(
    bash bin btop cava chrome dolphin fastfetch gtk hellwal hypr kitty matugen mpv rice rofi
    swayimg swaync telegram vim wallust waybar wlogout zsh
)

for package in "${packages[@]}"; do
    stow --dir="$ROOT" --target="$target" --restow "$package"
done
mkdir -p "$target/.config/systemd/user"
stow --dir="$ROOT" --target="$target" --no-folding --restow systemd

for path in \
    .config/hypr \
    .config/waybar \
    .config/kitty \
    .config/matugen/config.toml \
    .config/matugen/templates/palette.env \
    .config/hellwal/templates/palette.env \
    .config/rofi \
    .config/rofi/emoji.tsv \
    .local/bin \
    .local/bin/rice-resume \
    .local/bin/rice-keybinds \
    .local/bin/rice-calculator \
    .local/bin/rice-emoji \
    .local/bin/rice-screenshot \
    .local/bin/rice-contrast \
    .local/bin/theme-set \
    .local/bin/rice-theme \
    .local/share/rice/telegram-base.tdesktop-palette \
    .config/systemd/user/rice-sun.timer \
    .zshrc \
    .zshenv \
    .vimrc; do
    if [ ! -e "$target/$path" ]; then
        printf 'stow-smoke: missing %s\n' "$path" >&2
        exit 1
    fi
done

for module in monitors env look input autostart binds rules workspaces; do
    if [ ! -f "$target/.config/hypr/$module.lua" ]; then
        printf 'stow-smoke: missing Hyprland module %s\n' "$module" >&2
        exit 1
    fi
done

# Workspaces must stay numeric on both monitors and in Waybar.
grep -q 'workspace = tostring(workspace)' "$target/.config/hypr/monitors.lua"
for workspace in $(seq 1 10); do
    grep -q "\"$workspace\": \"$workspace\"" "$target/.config/waybar/config.jsonc"
done
grep -q 'rice-screenshot' "$target/.config/hypr/binds.lua"
grep -q '"custom/notification"' "$target/.config/waybar/config.jsonc"

# Satty must float, and OCR must stay off the workspace-number row.
grep -Fq 'com\\.gabm\\.satty' "$target/.config/hypr/rules.lua"
grep -q 'SHIFT + X' "$target/.config/hypr/binds.lua"

# Animation coverage: window movement, special workspaces, and wlogout.
grep -q 'windowsMove' "$target/.config/hypr/look.lua"
grep -q 'specialWorkspace' "$target/.config/hypr/look.lua"
grep -q 'logout_dialog' "$target/.config/hypr/rules.lua"
grep -q 'cubic-bezier(0.2, 0, 0, 1)' "$target/.config/wlogout/layouts/attached/style.css"
grep -q 'button:hover#lock' "$target/.config/wlogout/layouts/attached/style.css"
grep -q 'button:focus' "$target/.config/wlogout/layouts/attached/style.css"
grep -q 'selection_bg' "$target/.config/wallust/templates/wlogout-colors.css"
grep -q 'rice-logout' "$target/.config/hypr/binds.lua"
grep -q 'SHIFT + Backspace' "$target/.config/hypr/binds.lua"
[ -x "$target/.local/bin/rice-logout" ]
[ "$(grep -c '"label"' "$target/.config/wlogout/layout")" -eq 4 ]
[ -f "$target/.config/wlogout/icons/lock_white.png" ]
[ -f "$target/.config/wlogout/icons/lock_black.png" ]
[ -f "$target/.config/wlogout/icons/suspend_white.png" ]
[ -f "$target/.config/wlogout/icons/hibernate_black.png" ]

# Ten selectable layouts, each with its own geometry, JSON actions, and CSS.
for layout in attached grid pills cards capsule glass modern minimal mosaic compact; do
    [ -f "$target/.config/wlogout/layouts/$layout/style.css" ]
    [ -f "$target/.config/wlogout/layouts/$layout/layout" ]
    grep -q '^order=' "$target/.config/wlogout/layouts/$layout/layout.conf"
    grep -q '^buttons=' "$target/.config/wlogout/layouts/$layout/layout.conf"
    grep -q '@import "colors.css"' "$target/.config/wlogout/layouts/$layout/style.css"
    grep -q '@keyframes wl-in' "$target/.config/wlogout/layouts/$layout/style.css"
    grep -q 'animation: wl-in' "$target/.config/wlogout/layouts/$layout/style.css"
    grep -q 'cubic-bezier(0.55, 0, 0.28, 1.682)' "$target/.config/wlogout/layouts/$layout/style.css"
done
[ "$(find "$target/.config/wlogout/layouts" -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq 10 ]
HOME="$target" "$target/.local/bin/rice-logout" --list | grep -c 'HyDE Attached' >/dev/null

# hellwal is the default palette engine; an explicit RICE_THEME_ENGINE or the
# recorded engine marker overrides it.  Matugen and wallust remain available.
grep -Fq 'RICE_THEME_ENGINE:-$(cat' "$target/.local/bin/theme-apply"
grep -Fq 'engine=hellwal' "$target/.local/bin/theme-apply"
grep -q 'colors.surface_container_low' "$target/.config/matugen/templates/palette.env"
grep -q 'hellwal)' "$target/.local/bin/theme-apply"
grep -q '%%background.hex%%' "$target/.config/hellwal/templates/palette.env"

# Static themes ship with pre-validated light/dark palettes and theme wallpapers.
for theme_dir in "$target/.config/rice/themes"/*/; do
    grep -q '^name=' "$theme_dir/theme.conf"
    grep -q '^description=' "$theme_dir/theme.conf"
    grep -q '^wallpaper_root=' "$theme_dir/theme.conf"
    grep -q '^default_light=' "$theme_dir/theme.conf"
    grep -q '^default_dark=' "$theme_dir/theme.conf"
    grep -q '^selection_fg=' "$theme_dir/light.env"
    grep -q '^selection_fg=' "$theme_dir/dark.env"
    grep -q '^bar_danger=' "$theme_dir/light.env"
done
grep -q 'theme-set' "$target/.local/bin/rice-theme"

printf 'stow-smoke: all %d packages restored into an isolated HOME; numeric workspaces intact\n' "${#packages[@]}"
