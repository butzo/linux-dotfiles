#!/bin/sh
# kitty: when running inside kitty, use `kitten ssh` for correct terminfo on the
# remote. No install step — kitty is the terminal emulator itself.
load-kitty() {
    [ "$TERM" = "xterm-kitty" ] || return 0
    alias ssh='kitten ssh'
}
