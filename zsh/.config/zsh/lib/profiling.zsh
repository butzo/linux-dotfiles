#!/usr/bin/zsh
# Startup-optimization + profiling helpers. zcache-eval is the workhorse used by
# modules to avoid forking slow `eval "$(tool init)"` shims on every shell.

# Cache the output of an expensive shell-init command so each new shell sources
# a static file instead of forking the tool. Regenerates only when the cache is
# missing or the tool binary is newer than the cache.
#   usage: zcache-eval <name> <cmd> [args...]
zcache-eval() {
    local name="$1"; shift
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init/${name}.zsh"
    local bin; bin=$(command -v "$1") || return
    if [[ ! -r "$cache" || "$bin" -nt "$cache" ]]; then
        mkdir -p "${cache:h}"
        "$@" > "$cache"
    fi
    source "$cache"
}

# Measure interactive shell startup time. Runs N fresh interactive shells
# (default 10) and reports the average wall-clock cost. Use `zsh-profile` for a
# per-function breakdown of where that time goes.
zsh-startup-time() {
    local runs="${1:-10}" i start total=0
    zmodload zsh/datetime
    for ((i = 0; i < runs; i++)); do
        start=$EPOCHREALTIME
        zsh -i -c exit
        total=$((total + EPOCHREALTIME - start))
    done
    printf 'avg startup: %.0f ms over %d runs\n' "$((total / runs * 1000))" "$runs"
}

# Per-function startup breakdown via zprof. Spawns a profiled interactive shell
# and prints zprof's table (sort by the `self` column to find real hot spots).
zsh-profile() {
    zsh -i -c 'zmodload zsh/zprof; source ~/.zshrc >/dev/null 2>&1; zprof' 2>/dev/null
}
