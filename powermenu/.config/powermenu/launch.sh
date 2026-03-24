#!/bin/bash

debug_echo() {
    [ -n "$DEBUG" ] && echo "$@"
}

# Icon options:
# Lock:      󰌾  󰷛      
# Suspend:   󰤄  󰒲 󰏤    ⏸
# Hibernate: 󰒲 󰜗 󰤄 󰋊   
# Reboot:    󰜉       ⟳
# Logout:    󰗽 󰍃      
# Shutdown:  󰐥    󰤆   ⏻

ICON_SIZE="24000"
ICON_RISE="-5000"

entries="  <span size=\"$ICON_SIZE\" rise=\"$ICON_RISE\">󰤄</span>   Sleep
  <span size=\"$ICON_SIZE\" rise=\"$ICON_RISE\">󰏤</span>   Suspend
  <span size=\"$ICON_SIZE\" rise=\"$ICON_RISE\">󰒲</span>   Hibernate
  <span size=\"$ICON_SIZE\" rise=\"$ICON_RISE\">󰜉</span>   Reboot
  <span size=\"$ICON_SIZE\" rise=\"$ICON_RISE\">󰗽</span>   Logout
  <span size=\"$ICON_SIZE\" rise=\"$ICON_RISE\">󰐥</span>   Poweroff
  <span size=\"$ICON_SIZE\" rise=\"$ICON_RISE\">󰌾</span>   Lock"
selected=$(echo -e "$entries" | wofi --show dmenu --prompt "Power Menu" -E -i --cache-file /dev/null --lines 7  --allow-markup)

[ -z "$selected" ] && exit 0
selected="${selected##* }"  # Remove everything before the label

sleep 0.1  # Small delay to allow wofi to close properly

debug_echo "Selected: $selected"


case "$selected" in
    "Lock")
        debug_echo "Locking screen..."
        hyprlock
        ;;
    "Logout")
        debug_echo "Logging out..."
        hyprctl dispatch exit
        ;;
    "Suspend")
        debug_echo "Suspending..."
        hyprlock & sleep 0.5 && systemctl suspend
        ;;
    "Sleep")
        debug_echo "Sleeping..."  
        hyprlock & sleep 0.5 && systemctl sleep
        ;;
    "Hibernate")
        debug_echo "Hibernating..."   
        hyprlock & sleep 0.5 && systemctl hibernate
        ;;
    "Reboot")
        debug_echo "Rebooting..." 
        systemctl reboot
        ;;
    "Poweroff")
        echo "Powering off..."  
        systemctl poweroff
        ;;
esac

