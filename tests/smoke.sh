#!/usr/bin/env bash
# Fast repository checks that do not modify the live desktop.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
export PYTHONDONTWRITEBYTECODE=1
export TMPDIR="${TMPDIR:-/tmp/opencode}"
mkdir -p "$TMPDIR"

printf '%s\n' '== Shell and configuration syntax =='
while IFS= read -r -d '' script; do
    IFS= read -r shebang < "$script" || true
    case "$shebang" in
        *bash*) bash -n "$script" ;;
    esac
done < <(find bin/.local/bin tests -maxdepth 1 -type f -print0)
bash -n bash/.bashrc bash/.bash_profile tests/smoke.sh tests/stow-smoke.sh tests/failure-smoke.sh
python3 -B - <<'PY'
import ast
from pathlib import Path
paths = list(Path('bin/.local/bin').iterdir()) + list(Path('tests').glob('*.py'))
for path in paths:
    if path.is_file() and (path.suffix == '.py' or path.read_bytes().startswith(b'#!/usr/bin/env python3')):
        ast.parse(path.read_text(), filename=str(path))
print('Python syntax: ok')
PY
if command -v luac >/dev/null 2>&1; then
    for file in hypr/.config/hypr/*.lua swayimg/.config/swayimg/*.lua; do
        luac -p "$file"
    done
    echo 'Lua syntax: ok'
fi

printf '\n%s\n' '== Unit and fixture tests =='
python3 -B -m unittest discover -s tests -p 'test_*.py' -v

printf '\n%s\n' '== Failure propagation =='
bash tests/failure-smoke.sh

printf '\n%s\n' '== Fresh-profile Stow restoration =='
bash tests/stow-smoke.sh

printf '\n%s\n' '== Portability and repository hygiene =='
if grep -RIn --exclude='colors.*' --exclude-dir='__pycache__' '/home/amit' \
    bash hypr waybar rofi bin; then
    echo 'smoke: user-specific absolute path found' >&2
    exit 1
fi
git diff --check

if hyprctl monitors >/dev/null 2>&1; then
    printf '\n%s\n' '== Live Hyprland binding metadata =='
    "$ROOT/bin/.local/bin/rice-keybinds" --print >/dev/null
    echo 'Live keybind metadata: ok'
fi

if [ "${RICE_LIVE_CHECKS:-0}" = 1 ]; then
    printf '\n%s\n' '== Live desktop health (explicit opt-in) =='
    rice-doctor
fi

printf '\n%s\n' 'smoke: all requested checks passed'
