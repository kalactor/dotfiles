#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='eza --icons --group-directories-first'
alias grep='grep --color=auto'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -lah --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
PS1='[\u@\h \W]\$ '

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ] && command -v fnm >/dev/null 2>&1; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell bash)"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell bash)"
fi

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

# Minimal system summary once per kitty window (not in nested shells)
if [[ -n "$KITTY_WINDOW_ID" && "$RICE_FASTFETCH_SHOWN" != "$KITTY_WINDOW_ID" ]] \
   && command -v fastfetch >/dev/null 2>&1; then
  export RICE_FASTFETCH_SHOWN="$KITTY_WINDOW_ID"
  fastfetch -c ~/.config/fastfetch/terminal-startup-config.jsonc
fi

# User scripts first, so ~/.local/bin/wall wins over /usr/bin/wall
export PATH="$HOME/.local/bin:$PATH"

# Directionally Local (dl)
export PATH="$HOME/.directionallylocal/bin:$PATH"
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Editor
export EDITOR=vim
export VISUAL=vim

# Prompt, directory jumping and fuzzy history
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
