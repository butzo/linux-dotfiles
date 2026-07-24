#!/usr/bin/zsh
# Per-package modules. Sources the lib/ helpers (loader, install, update,
# profiling), then activates each package via `load-module`.

ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

# Load library helpers first (defines load-module, ensure-pkg, zcache-eval, ...).
# Alphabetical glob order is fine: every helper is defined before the first
# load-module call below.
for _lib in "$ZDOTDIR"/lib/*.zsh(N); do
	source "$_lib"
done
unset _lib

# Active modules. Each sources modules/<name>.* and runs its load-<name> hook,
# which handles install-if-missing + config. zoxide stays last so its `cd` shim
# wins (and zoxide stops warning about init order).
# load-module bat
load-module code
load-module eza
load-module fzf
load-module lazygit
load-module nvim
load-module kitty
load-module paru
load-module rnote
load-module udisksctl
load-module wallpaper
load-module zoxide

# Opt-in modules (uncomment to enable):
# load-module advmv   # overrides `mv` with advcpmv (progress bars)
# load-module gitui
# load-module paru

# ESP-Matter: only load the heavy SDK shim when the SDK is actually present.
[[ -d "$HOME/git/esp-matter" ]] && load-module matter
