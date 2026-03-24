#!/usr/bin/env bash

set -euo pipefail

# exec {lock_fd}<>"/tmp/wallpaper.lock"
# if ! flock -n "$lock_fd"; then
#   echo "$(date -Is) [INFO] concurrent run - skipped"
#   exit 0
# fi

DEBUG_WAYPAPER_SERVICE=1

debug_echo() {
    [[ -n "${DEBUG_WAYPAPER_SERVICE:-}" ]] || return 0
    printf '%s\n' "$*"
}

WALLPAPER_LINK="$HOME/.config/wallpaper/.current_wallpaper"

debug_echo "[set_wallpaper.sh] WALLPAPER_LINK is $WALLPAPER_LINK"

if [[ -n "${1:-}" ]]; then
    if [[ ! -f "$1" ]]; then
        echo "Error: File not found: $1" >&2
        echo "Usage: $(basename "$0") [WALLPAPER_FILE]" >&2
        exit 1
    fi
    debug_echo "[set_wallpaper.sh] Linking wallpaper: $WALLPAPER_LINK to $1"
    ln -snf "$1" "$WALLPAPER_LINK"
    # cp --reflink=auto "$1" "$WALLPAPER_LINK"
    debug_echo "[set_wallpaper.sh] WALLPAPER_LINK $WALLPAPER_LINK -> $(readlink -e "$WALLPAPER_LINK")"
fi


pkill -USR2 hyprlock ||  true
echo "[set_wallpaper.sh] Sent USR2 to hyprlock to update wallpaper"


"$(dirname "$0")/matugen.sh" || true
echo "[set_wallpaper.sh] Ran matugen to generate colorscheme based on wallpaper"

wallpaper_backend=hyprpaper
# wallpaper_backend=swaybg
# wallpaper_backend=awww

echo "[set_wallpaper.sh] Set wallpaper using backend: $wallpaper_backend"
"$(dirname "$0")/$wallpaper_backend.sh"
