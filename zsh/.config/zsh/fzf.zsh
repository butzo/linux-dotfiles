#!/usr/bin/zsh

# Check if eza is installed, otherwise use ls
if command -v eza &> /dev/null; then
    PREVIEW_CMD='eza --icons=always $realpath'
else
    PREVIEW_CMD='ls -la $realpath'
fi

zstyle ':fzf-tab:complete:cd:*' fzf-preview "$PREVIEW_CMD"
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview "$PREVIEW_CMD"
eval "$(fzf --zsh)"

