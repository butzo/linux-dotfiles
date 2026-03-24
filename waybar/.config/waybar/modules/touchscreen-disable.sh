#!/bin/bash

HYPRLAND_INPUT_CONFIG_FILE="$HOME/.config/hypr/config/input.conf"
if [ ! -f "$HYPRLAND_INPUT_CONFIG_FILE" ]; then
	notify-send "Waybar Module Touchscreen" "Hyprland input config file not found: $HYPRLAND_INPUT_CONFIG_FILE"
	exit 1
fi

get_touchscreen_status() {
	grep -A5 'name = gxtp7936' "$HYPRLAND_INPUT_CONFIG_FILE" | grep 'enabled' | sed -E 's/.*enabled = (.*)/\1/'
}

# Handle argument: 0,1,2,3 reset
if [ -n "$1" ]; then
	if [ "$1" = "reset" ]; then
		STATUS="true"
	elif [ "$1" = "toggle" ]; then
		CURRENT=$(get_touchscreen_status)
		case "$CURRENT" in
			"true") STATUS="false" ;;
			"false") STATUS="true" ;;
			*) STATUS="true" ;;
		esac
	else
		STATUS="$1"
	fi
	sed -i "/name = gxtp7936:00-27c6:0123/,/^}/s/enabled = .*/enabled = $STATUS/" "$HYPRLAND_INPUT_CONFIG_FILE"
else
	# No argument: read mode from config file
	STATUS=$(get_touchscreen_status)
fi



# Output JSON for waybar
if [ "$STATUS" = "true" ]; then
	echo '{"text": "🔓", "tooltip": "Touchscreen enabled"}'
elif [ "$STATUS" = "false" ]; then
	echo '{"text": "🔒", "tooltip": "Touchscreen disabled"}'
fi