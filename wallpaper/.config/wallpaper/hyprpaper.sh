#!/usr/bin/env bash

# WALLPAPER_LINK="$1"
DEBUG_WAYPAPER_SERVICE=1

debug_echo() {
    [[ -n "${DEBUG_WAYPAPER_SERVICE:-}" ]] || return 0
    printf '%s\n' "$*"
}

# if [[ -z "$WALLPAPER_LINK" ]]; then
#     echo "Error: Wallpaper link is required as first argument" >&2
#     echo "Usage: $0 <wallpaper_path>" >&2
#     exit 1
# fi

# Start hyprpaper if not running
if ! pgrep -x hyprpaper > /dev/null; then
    debug_echo "Starting hyprpaper"
    hyprctl dispatch exec hyprpaper
fi
# pgrep -x hyprpaper > /dev/null || hyprpaper &

WALLPAPER_LINK="$HOME/.config/wallpaper/.current_wallpaper"

if [[ ! -f "$WALLPAPER_LINK" ]]; then
    debug_echo "Error: Wallpaper file not found at $WALLPAPER_LINK" >&2
    exit 1
fi

debug_echo "[hyprpaper.sh] $WALLPAPER_LINK"

# debug_echo "hyprpaper unloading all ok?"
# hyprctl hyprpaper unload all
# debug_echo "hyprpaper preloading $WALLPAPER_LINK ok?"
# hyprctl hyprpaper preload "$WALLPAPER_LINK"

# add matugen or wallust here
debug_echo "[hyprpaper.sh] Available outputs: $(hyprctl monitors -j | jq -r '.[] | .name')"

for monitor in $(hyprctl monitors all -j | jq -r '.[] | .name'); do
    debug_echo "[hyprpaper.sh] Setting wallpaper for monitor: $monitor"
    hyprctl hyprpaper wallpaper "$monitor, $WALLPAPER_LINK"
    debug_echo "[hyprpaper.sh] hyprctl exit status: $?"
done

# for monitor in $(hyprctl monitors -j | jq -r '.[] | .name'); do
#     hyprctl hyprpaper reload "$monitor,$WALLPAPER_LINK"
# done