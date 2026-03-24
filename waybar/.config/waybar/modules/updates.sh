#!/usr/bin/zsh

utils_zsh="$HOME/.config/zsh/utils.zsh"

if [[ ! -f "$utils_zsh" ]]; then
    notify-send "Error" "utils.zsh not found at $utils_zsh"
    return 1
fi

source "$utils_zsh"

case "${1:-count}" in
    count|cu|c)
        count-updates
        ;;
    update|ua|u)
        update-all
        ;;
    --help|help|-h)
        echo "Usage: updates.sh [count|update]"
        echo "  count  - Show number of available updates (default)"
        echo "  update - Install all available updates"
        ;;
    *)
        echo "Usage: updates.sh [count|update]"
        echo "  count  - Show number of available updates (default)"
        echo "  update - Install all available updates"
        return 1
        ;;
esac