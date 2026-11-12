#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# fnm
FNM_PATH="/home/amit/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell bash)"
fi

eval "$(fnm env --use-on-cd --shell bash)"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

fastfetch -c ~/.config/fastfetch/terminal-startup-config.jsonc

# User scripts first, so ~/.local/bin/wall wins over /usr/bin/wall
export PATH="$HOME/.local/bin:$PATH"

# Directionally Local (dl)
export PATH="/home/amit/.directionallylocal/bin:$PATH"
. "$HOME/.cargo/env"

# Editor
export EDITOR=vim
export VISUAL=vim
