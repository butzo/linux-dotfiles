#!/usr/bin/zsh
# zoxide: smarter `cd`. Loaded last among modules so its `cd` shim wins, which
# also silences zoxide's "initialize at end of config" doctor warning.
load-zoxide() {
    ensure-pkg zoxide || return
    # Cache `zoxide init` so each shell sources a static file instead of forking.
    zcache-eval zoxide zoxide init --cmd cd zsh
}
