#!/usr/bin/env bash
set -euo pipefail


action="${1:-copysave}"
target="${2:-area}"

if [[ "$action" == "--help" ]]; then
  cat << 'EOF'
Usage: screenshot.sh [action] [target]

Actions:
  copy      - Copy screenshot to clipboard
  copysave  - Copy to clipboard and prompt to save (default)
  --help    - Display this help message

Targets:
  area      - Select area (default)
  screen    - Entire screen
  output    - Active output
  window    - Active window
EOF
  exit 0
fi

# Temporary file
tmpfile=$(mktemp /tmp/screenshot.XXXXXX.png)

# Take screenshot based on action
grimblast "$action" "$target" "$tmpfile" >/dev/null 2>&1 || exit 1

# If action doesn't contain "save", just exit
if [[ "$action" != *"save"* ]]; then
    echo "Screenshot copied to clipboard."
    exit 0
fi

# Open Alacritty with zsh prompt for save path
alacritty --class "screenshot-save" -e zsh -ic "
echo 'Screenshot copied to clipboard.'
vared -p 'Save path (Enter to skip): ' -c savepath

if [[ -n \"\${savepath// }\" ]]; then
  expanded_path=\$(eval echo \"\$savepath\")
  mkdir -p \"\$(dirname \"\$expanded_path\")\"
  mv \"$tmpfile\" \"\$expanded_path\"
fi
"