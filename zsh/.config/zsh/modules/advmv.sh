#!/bin/sh
# advcpmv: cp/mv with progress bars (https://github.com/jarun/advcpmv).
# No distro package — built from the upstream installer into /usr/local/bin.
# Opt-in: not loaded by default since it overrides `mv`.
load-advmv() {
    ensure-custom advmv _install-advcpmv || return
    alias cpg='/usr/local/bin/advcp -g'
    alias mv='mvg'
    alias mvg='/usr/local/bin/advmv -g'
}

_install-advcpmv() {
    echo "Installing advcpmv from upstream..."
    local d
    d=$(mktemp -d) || return 1
    git clone https://github.com/jarun/advcpmv "$d" || return 1
    ( cd "$d" && sh ./install.sh ) || return 1
    sudo install -m755 "$d/advcp" /usr/local/bin/advcp || return 1
    sudo install -m755 "$d/advmv" /usr/local/bin/advmv || return 1
}
