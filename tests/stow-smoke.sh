#!/usr/bin/env bash
# Verify all stow packages install into an isolated HOME without touching it.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP_BASE="${TMPDIR:-/tmp/opencode}"
mkdir -p "$TMP_BASE"
target=$(mktemp -d "$TMP_BASE/rice-stow.XXXXXXXX")
trap 'rm -rf "$target"' EXIT

packages=(
    bash bin btop cava chrome dolphin fastfetch gtk hypr kitty matugen mpv rice rofi
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
    .config/rofi \
    .config/rofi/emoji.tsv \
    .local/bin \
    .local/bin/rice-resume \
    .local/bin/rice-keybinds \
    .local/bin/rice-calculator \
    .local/bin/rice-emoji \
    .local/bin/rice-screenshot \
    .local/bin/rice-contrast \
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
grep -q 'wlogout-tile-in' "$target/.config/wlogout/style.css"

# matugen is the active palette engine; wallust remains the fallback.
grep -q 'RICE_THEME_ENGINE:-matugen' "$target/.local/bin/theme-apply"
grep -q 'colors.surface_container_low' "$target/.config/matugen/templates/palette.env"

printf 'stow-smoke: all %d packages restored into an isolated HOME; numeric workspaces intact\n' "${#packages[@]}"
