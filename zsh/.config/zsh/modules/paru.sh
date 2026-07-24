#!/bin/sh
# paru: AUR helper. Short pacman/paru aliases. Install via the AUR bootstrap
# helper (no distro package for paru itself).
load-paru() {
    ensure-custom paru install-aur_helper paru || return
    alias pacclean='paru -Sc'
    alias pacclr='paru -Scc'
    alias paupg='paru -Syu'
    alias pasu='paru -Syu --noconfirm'
    alias pain='paru -S'
    alias pains='paru  -U'
    alias pare='paru -R'
    alias parem='paru -Rns'
    alias parep='paru -Si'
    alias pareps='paru -Ss'
    alias paloc='paru -Qi'
    alias palocs='paru -Qs'
    alias palst='paru -Qe'
    alias paorph='paru -Qtd'
    alias painsd='paru -S --asdeps'
    alias pamir='paru -Syy'
    alias paupd='paru -Sy'
}
