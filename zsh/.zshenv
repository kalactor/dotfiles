#
# ~/.zshenv
#

# User scripts first, so ~/.local/bin/wall wins over /usr/bin/wall.
# `typeset -U path` keeps entries unique if this file is sourced twice.
typeset -U path
path=(
    "$HOME/.local/bin"
    "$HOME/.directionallylocal/bin"
    "$HOME/.cargo/bin"
    "$HOME/.local/share/fnm"
    $path
)
export PATH

export EDITOR=vim
export VISUAL=vim
