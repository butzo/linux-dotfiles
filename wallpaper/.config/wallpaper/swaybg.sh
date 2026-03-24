#!/usr/bin/env bash

debug_echo() {
    [[ -n "${DEBUG_WAYPAPER_SERVICE:-}" ]] || return 0
    printf '%s\n' "$*"
}

WALLPAPER_LINK="$HOME/.config/wallpaper/.current_wallpaper"

# Start new swaybg instance
swaybg --image "$WALLPAPER_LINK" --mode fill &
NEW_PID=$!

# Kill all other swaybg instances
sleep 0.2
pgrep -f swaybg | grep -v "^$NEW_PID$" | xargs -r kill -9 2>/dev/null
