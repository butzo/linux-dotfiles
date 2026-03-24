# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ZINIT plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    #git clone -v git://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    git clone -v https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Add zsh plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light  zsh-users/zsh-syntax-highlighting
zinit light  zsh-users/zsh-completions
zinit light  zsh-users/zsh-autosuggestions
zinit light  Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::archlinux
zinit snippet OMZP::aliases
zinit snippet OMZP::alias-finder
# zinit snippet OMZP::command-not-found
zinit snippet OMZP::git
zinit snippet OMZP::man
zinit snippet OMZP::nmap
zinit snippet OMZP::sudo
#zinit snippet OMZP::chucknorris
# zinit snippet OMZP::tailscale
# zinit snippet OMZP::tmux
# zinit snippet OMZP::ufw

# Load completitions
autoload -U compinit && compinit
_comp_options+=(globdots)

# Keybindings
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

# History
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
setopt hist_save_no_dups
setopt interactive_comments

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

if ! command -v eza &> /dev/null; then
    alias ls='ls --color'
    alias ll='ls -la'
    alias la='ls -a'
fi

if [ -f "$HOME/.config/zsh/utils.zsh" ]; then
    source "$HOME/.config/zsh/utils.zsh"
else
    echo "Error: $HOME/.config/zsh/utils.zsh not found"
fi

if command -v advmv &> /dev/null; then
    load-zsh-config advmv
fi

load-zsh-config code
load-zsh-config eza
load-zsh-config fzf
# load-zsh-config gitui
load-zsh-config lazygit
load-zsh-config nvim
load-zsh-config kitty
load-zsh-config paru
load-zsh-config udisksctl
load-zsh-config zoxide

alias watch='watch --color -n 0.5'

alias cp='cp --reflink=auto' # Use copy-on-write for cp

alias open='xdg-open'

if find "$HOME" -maxdepth 2 -type d -name "esp-matter" -quit &> /dev/null; then
    source "$HOME/.config/zsh/matter.zsh"
fi



# The following lines were added by compinstall
#zstyle :compinstall filename '/home/christoph/.zshrc'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
