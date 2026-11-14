#
# ~/.zshrc
#

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt SHARE_HISTORY EXTENDED_HISTORY HIST_VERIFY
setopt NO_BEEP INTERACTIVE_COMMENTS

# Completion
zmodload zsh/complist
autoload -Uz compinit
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$cache_dir"
compinit -d "$cache_dir/zcompdump-$ZSH_VERSION"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$cache_dir/zcompcache"
setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END

# Aliases
alias ls='eza --icons --group-directories-first'
alias grep='grep --color=auto'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -lah --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'

# fnm
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Kiro shell integration
if [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1; then
  source "$(kiro --locate-shell-integration-path zsh)"
fi

# Minimal system summary once per kitty window (not in nested shells)
if [[ -n "$KITTY_WINDOW_ID" && "$RICE_FASTFETCH_SHOWN" != "$KITTY_WINDOW_ID" ]] \
   && command -v fastfetch >/dev/null 2>&1; then
  export RICE_FASTFETCH_SHOWN="$KITTY_WINDOW_ID"
  fastfetch -c ~/.config/fastfetch/terminal-startup-config.jsonc
fi

# Fish-like autosuggestions and history search.  The plugin enables async
# mode itself on zsh >= 5.0.8.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Prompt, directory jumping and fuzzy history
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
if [[ -t 0 ]] && command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

# Syntax highlighting must load last.  The generated file comes after it so
# its styles replace the plugin defaults.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r "$HOME/.cache/rice/zsh-colors.zsh" ]] && source "$HOME/.cache/rice/zsh-colors.zsh"
