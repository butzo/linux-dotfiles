#!/bin/sh
# bat: `cat` clone with syntax highlighting. Debian/Ubuntu ship the binary as
# `batcat` (the `bat` name clashes with another package), so detect either.
load-bat() {
    bat_bin=""
    if command -v batcat >/dev/null 2>&1; then
        bat_bin=$(command -v batcat)
    elif command -v bat >/dev/null 2>&1; then
        bat_bin=$(command -v bat)
    fi

    # Neither name present: offer to install, then re-detect.
    if [ -z "$bat_bin" ]; then
        ensure-pkg bat || return
        bat_bin=$(command -v batcat || command -v bat)
    fi

    alias rcat="$(command -v cat)"
    alias cat="$bat_bin"
    export MANPAGER="sh -c 'col -bx | $bat_bin -l man -p'"
    export MANROFFOPT="-c"
}
