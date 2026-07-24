#!/bin/sh
# VS Code: store credentials in the libsecret keyring (stops the keyring nag).
load-code() {
    ensure-pkg code || return
    alias code='code --password-store=gnome-libsecret'
}
