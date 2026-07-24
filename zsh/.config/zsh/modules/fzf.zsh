#!/usr/bin/zsh
# fzf + fzf-tab previews. zsh-specific (zstyle/fzf-tab), hence the .zsh module.
load-fzf() {
    ensure-pkg fzf || return

    # Prefer eza for directory previews, fall back to ls.
    local preview
    if command -v eza &>/dev/null; then
        preview='eza --icons=always $realpath'
    else
        preview='ls -la $realpath'
    fi
    zstyle ':fzf-tab:complete:cd:*' fzf-preview "$preview"
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview "$preview"

    # Cache `fzf --zsh` so each shell sources a static file instead of forking.
    zcache-eval fzf fzf --zsh
}
