#!/bin/bash

CONFIG_FILE="$HOME/.config/hypr/config/input.conf"
DEVICE_NAME="wcom016a:00-2d1f:0185-stylus"

# Get current wacom output from config
get_current_output() {
    grep -A5 "name = $DEVICE_NAME" "$CONFIG_FILE" | grep 'output = ' | sed 's/.*output = //' | xargs
}

# Print status for waybar (JSON)
print_status() {
    local current=$(get_current_output)
    
    # Return nothing if eDP-1 (module hides)
    # if [[ "$current" == "eDP-1" || -z "$current" ]]; then
    #     exit 0
    # fi
    external_count=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')
    if [[ "$external_count" -eq 0 ]]; then
        exit 0
    fi

    # Get full info for the current monitor
    if command -v hyprctl &> /dev/null; then
        local info=$(hyprctl monitors -j | jq -r --arg id "$current" '.[] | select(.name == $id) | "\(.width)x\(.height)|\(.x),\(.y)|\(.activeWorkspace.name)"' 2>/dev/null)
        if [[ -n "$info" ]]; then
            IFS='|' read -r resolution location workspace <<< "$info"
            echo "{\"text\": \"🖋️ $current\", \"alt\": \"$current | $resolution @ $location | $workspace\", \"tooltip\": \"Wacom mapped to $current\"}"
            exit 0
        fi
    fi
    
    # Fallback
    echo "{\"text\": \"🖥️ $current\", \"alt\": \"$current\", \"tooltip\": \"Wacom mapped to $current\"}"
}

select_output() {
    # Check if hyprctl is available
    if ! command -v hyprctl &> /dev/null; then
        notify-send "Error" "hyprctl not found. Is Hyprland running?"
        exit 1
    fi

    # Get monitor info from hyprctl and format it
    monitors=$(hyprctl monitors -j | jq -r '.[] | "\(.name)|\(.width)x\(.height)|\(.x),\(.y)|\(.activeWorkspace.name)"')

    # Build the menu entries with emojis
    menu=""
    count=0
    while IFS='|' read -r id resolution location workspace; do
        # Choose emoji based on monitor name
        if [[ "$id" == *"eDP"* ]]; then
            emoji="💻"  # Laptop
        elif [[ "$id" == *"DP"* ]]; then
            emoji="🖥️"  # Desktop monitor
        elif [[ "$id" == *"DVI"* ]]; then
            emoji="🖥️"  # DVI monitor
        elif [[ "$id" == *"HDMI"* ]]; then
            emoji="📺"  # HDMI/TV
        else
            emoji="🖵"  # Generic monitor
        fi
        
        entry="$emoji  $id | $resolution@$location | $workspace"
        if [ -z "$menu" ]; then
            menu="$entry"
        else
            menu="$menu\n$entry"
        fi
        ((count++))
    done <<< "$monitors"

    # Show wofi menu with exact line count
    selected=$(echo -e "$menu" | wofi --show dmenu --prompt "Select output" -i --cache-file /dev/null --lines "$count"
    )

    [ -z "$selected" ] && exit 0

    # Extract the monitor ID from the selection (first field after emoji)
    monitor_id=$(echo "$selected" | sed 's/^[^a-zA-Z]*//' | awk -F' \| ' '{print $1}' | xargs)

    sed -i "/name = wcom016a:00-2d1f:0185-stylus/,/^}/s/output = .*/output = $monitor_id/" ~/.config/hypr/config/input.conf
}

# Handle arguments: none/status = print status, select = open wofi
case "${1:-status}" in
    status)
        print_status
        exit 0
        ;;
    select)
        select_output
        print_status
        exit 0
        ;;
    *)
        echo "Usage: $0 [status|select]" >&2
        exit 1
        ;;
esac
