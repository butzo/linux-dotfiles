#!/usr/bin/zsh
# Plugin manager, prompt, and completion. Kept together because load ORDER is
# load-bearing: completions must populate $fpath before compinit, and syntax
# highlighting must wrap the final widget set last.

# ZINIT plugin manager — bootstrap on first run.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone -v https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Zinit never auto-updates (unlike pacman packages) — nudge every 30 days.
# FETCH_HEAD is touched by `zinit self-update`; HEAD covers the fresh-clone
# case where FETCH_HEAD doesn't exist yet. (N.mM-1): modified < 1 month ago.
if ! (){ local -a f=("$ZINIT_HOME"/.git/{FETCH_HEAD,HEAD}(N.mM-1)); (( $#f )) }; then
    print -P "%F{yellow}zinit: no update in >30 days — run: zinit self-update && zinit update --all -p%f"
fi

# Prompt: load immediately — p10k instant-prompt (in .zshrc) depends on it.
zinit ice depth=1; zinit light romkatv/powerlevel10k

# zsh-completions must populate $fpath BEFORE compinit runs, so it stays
# synchronous. `blockf` lets zinit manage its fpath entry cleanly.
zinit ice blockf
zinit light zsh-users/zsh-completions

# Load completions. Skip the slow compaudit security check when the dump is
# < 1h old (-C); full rebuild + audit otherwise. The (#qN.mh+1) glob qualifier
# matches the dump only when it is older than 1 hour.
autoload -Uz compinit
zdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
if [[ -n $zdump(#qN.mh+1) || ! -e $zdump ]]; then
    compinit -d "$zdump"
else
    compinit -C -d "$zdump"
fi
unset zdump

# Replay compdef calls captured by zinit before compinit ran.
zinit cdreplay -q

# Deferred plugins (turbo `wait lucid`): load a few ms AFTER the first prompt
# paints instead of blocking startup. Order matters: fzf-tab needs compinit
# (done above); zsh-syntax-highlighting MUST be last so it wraps every widget.
zinit wait lucid for \
    Aloxaf/fzf-tab \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting

# Deferred Oh-My-Zsh snippets (aliases/functions; fine to load after prompt).
zinit wait lucid for \
    OMZP::archlinux \
    OMZP::aws \
    OMZP::aliases \
    OMZP::alias-finder \
    OMZP::git \
    OMZP::man \
    OMZP::nmap \
    OMZP::sudo

# Completion styling.
_comp_options+=(globdots)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes
