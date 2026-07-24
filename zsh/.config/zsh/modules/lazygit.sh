#!/bin/sh
# lazygit: terminal UI for git.
load-lazygit() {
    ensure-pkg lazygit || return
    alias lg='lazygit'
}
