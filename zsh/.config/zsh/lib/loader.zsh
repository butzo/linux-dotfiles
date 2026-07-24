#!/usr/bin/zsh
# Module loader. Replaces the old `load-zsh-config`. Each package lives in
# modules/<name>.{sh,bash,zsh} and defines a `load-<name>()` function holding
# its own install logic + config. `load-module <name>` wires that up.

ZSH_MODULE_DIR="${ZDOTDIR:-$HOME/.config/zsh}/modules"

# load-module <name>
# Source modules/<name>.{sh,bash,zsh} (defining load-<name>), then run
# load-<name> so the module can ensure its package is installed and apply its
# aliases/config. One call-site convention, each module owns its own logic.
load-module() {
    local name="$1"
    # Native zsh glob (no `find` fork): (N) nullglob, (-) follow symlinks,
    # (.) regular files, ([1]) first match. Only .sh/.bash/.zsh are accepted so
    # modules can be written in whichever shell suits, for cross-shell reuse.
    local file=("$ZSH_MODULE_DIR/${name}".(sh|bash|zsh)(N-.[1]))
    if [[ ! -r "$file" ]]; then
        echo "load-module: module '$name' not found in $ZSH_MODULE_DIR" >&2
        return 1
    fi
    source "$file"
    # Run the module's hook if it defined one. `$+functions[...]` is a cheap
    # builtin lookup — no fork — so this stays fast on every shell.
    (( $+functions[load-${name}] )) && "load-${name}"
}
