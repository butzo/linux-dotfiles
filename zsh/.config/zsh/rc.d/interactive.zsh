#!/usr/bin/zsh
# Interactive-shell behaviour: keybindings, history, options, and small global
# aliases that don't belong to any one package.

# Keybindings.
bindkey -e # Emacs
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^ ' autosuggest-accept

# History.
HISTSIZE=20000
HISTFILE=~/.histfile
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt interactive_comments

# Plain-ls fallbacks — only when eza's module didn't claim these aliases.
if ! command -v eza &>/dev/null; then
	alias ls='ls --color'
	alias ll='ls -la'
	alias la='ls -a'
fi

# Small global aliases.
alias watch='watch --color -n 0.5'
alias cp='cp --reflink=auto' # copy-on-write where the filesystem supports it
alias open='xdg-open'

alias die='sudo rm -rf'
