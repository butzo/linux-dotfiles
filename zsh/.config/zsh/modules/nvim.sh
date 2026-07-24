#!/bin/sh
# Neovim as the default editor. Binary is `nvim`, package is `neovim`.
load-nvim() {
    ensure-pkg nvim neovim || return
    export EDITOR=nvim
    alias vi=nvim
    alias vim=nvim
}
