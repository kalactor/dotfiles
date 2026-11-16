#!/usr/bin/env bash
# Exercise error propagation with isolated HOMEs and harmless command stubs.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP_BASE="${TMPDIR:-/tmp/opencode}"
mkdir -p "$TMP_BASE"
work=$(mktemp -d "$TMP_BASE/rice-failure-test.XXXXXXXX")
trap 'rm -rf "$work"' EXIT
home="$work/home"
stub="$work/stub"
mkdir -p "$home/.local/bin" "$home/Pictures/walls/light" "$stub" \
    "$home/.config/hellwal/templates" "$home/.config/wallust/templates"
printf 'background=#%%background.hex%%\n' > "$home/.config/hellwal/templates/palette.env"
# The shared application templates live in the legacy wallust package; an
# empty manifest keeps rice-contrast quiet when this isolated HOME has none.
printf '[templates]\n' > "$home/.config/wallust/wallust.toml"
printf 'fixture\n' > "$home/wall.jpg"
printf 'fixture\n' > "$home/Pictures/walls/light/a.jpg"

for command in gsettings swaync-client notify-send pkill; do
    printf '#!/bin/sh\nexit 0\n' > "$stub/$command"
    chmod +x "$stub/$command"
done
# hellwal normally renders the base palette into its output folder.  The stub
# keeps that contract without needing an image decoder.
cat > "$stub/hellwal" <<'EOF'
#!/bin/sh
out=
while [ "$#" -gt 0 ]; do
    case "$1" in
        -o) out=$2; shift 2 ;;
        *) shift ;;
    esac
done
[ -n "$out" ] || exit 1
mkdir -p "$out"
cat > "$out/palette.env" <<'PALETTE'
background=#C7B9B9
foreground=#6B6E33
cursor=#867F2A
color0=#AB9E9E
color1=#767184
color2=#A08F20
color3=#0AA2D3
color4=#8FB8A2
color5=#FA9871
color6=#EEF572
color7=#6B6E33
color8=#230001
color9=#767184
color10=#A08F20
color11=#0AA2D3
color12=#8FB8A2
color13=#FA9871
color14=#EEF572
color15=#242511
PALETTE
exit 0
EOF
chmod +x "$stub/hellwal"
cp "$ROOT/bin/.local/bin/rice-contrast" "$home/.local/bin/rice-contrast"
chmod +x "$home/.local/bin/rice-contrast"
printf '#!/bin/sh\nexit 1\n' > "$stub/hyprctl"
printf '#!/bin/sh\nprintf "light\\n"\n' > "$stub/rice-mode"
printf '#!/bin/sh\nprintf "light\\n"\n' > "$home/.local/bin/rice-mode"
chmod +x "$stub/hyprctl" "$stub/rice-mode" "$home/.local/bin/rice-mode"

for helper in kde-theme dolphin-view-defaults rice-gtk-reload; do
    printf '#!/bin/sh\nexit 0\n' > "$home/.local/bin/$helper"
    chmod +x "$home/.local/bin/$helper"
done
cat > "$home/.local/bin/telegram-theme" <<'EOF'
#!/bin/sh
exit "${FAKE_TELEGRAM_EXIT:-0}"
EOF
chmod +x "$home/.local/bin/telegram-theme"

run_env=(env HOME="$home" PATH="$stub:/usr/bin:/bin")

# A complete theme application writes its completion marker.
"${run_env[@]}" "$ROOT/bin/.local/bin/theme-apply" "$home/wall.jpg" light
[ "$(cat "$home/.cache/rice/theme-mode")" = light ]
[ "$(cat "$home/.cache/rice/theme-engine")" = hellwal ]
rm "$home/.cache/rice/theme-mode"

# A secondary generator failure is reported and the marker stays incomplete.
if "${run_env[@]}" FAKE_TELEGRAM_EXIT=1 \
    "$ROOT/bin/.local/bin/theme-apply" "$home/wall.jpg" light \
    >"$work/failure.out" 2>&1; then
    echo 'failure-smoke: theme-apply hid a generator failure' >&2
    exit 1
fi
[ ! -e "$home/.cache/rice/theme-mode" ]
grep -q 'Telegram theme generation/sync failed' "$work/failure.out"

# Wallpaper changes also propagate the failed theme application.
printf '#!/bin/sh\nexit 1\n' > "$home/.local/bin/theme-apply"
chmod +x "$home/.local/bin/theme-apply"
if "${run_env[@]}" "$ROOT/bin/.local/bin/wall" next >"$work/wall.out" 2>&1; then
    echo 'failure-smoke: wall hid a theme failure' >&2
    exit 1
fi
[ "$(cat "$home/.cache/rice/effective-mode")" = light ]

# A missing/incomplete installation makes doctor fail for scripts and CI.
if env HOME="$work/empty-home" PATH="/usr/bin:/bin" \
    "$ROOT/bin/.local/bin/rice-doctor" >"$work/doctor.out" 2>&1; then
    echo 'failure-smoke: doctor returned success for an incomplete HOME' >&2
    exit 1
fi
grep -Eq 'Summary: [1-9][0-9]* failure' "$work/doctor.out"

printf 'failure-smoke: helper, wallpaper and doctor failures are visible\n'
