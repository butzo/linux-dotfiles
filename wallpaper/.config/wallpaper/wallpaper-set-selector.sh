#!/usr/bin/env bash
set -euo pipefail  # Exit on error, unset vars, and failed pipes


# Check for required wallpaper directory argument
if [ $# -eq 0 ]; then
  echo "Error: No wallpaper directory argument provided." >&2
  exit 1
fi
wallpaper_dir="$1"

# Read ignore patterns from .ignore file
ignore_file="$wallpaper_dir/.ignore"
prune_args=()
if [ -f "$ignore_file" ]; then
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    [ -n "$pattern" ] && prune_args+=(-name "$pattern" -o)
  done < "$ignore_file"
  # Remove last -o if patterns exist
  [ ${#prune_args[@]} -gt 0 ] && unset 'prune_args[-1]'
fi

# echo "Using wallpaper directory: $wallpaper_dir"
# echo prune_args: "${prune_args[*]}"

# Build wallpaper set list, show selector with images if available
choice="$(
  find "$wallpaper_dir" -mindepth 1 -maxdepth 2 \
    ${prune_args:+\( "${prune_args[@]}" \) -prune -o} \
    -type d -printf '%P\n' \
  | sort \
  | while IFS= read -r rel; do
      dir="$wallpaper_dir/$rel"
      icon="$dir/icon"
      if [ -f "$icon" ]; then
        printf 'img:%s:text:%s\n' "$icon" "$rel"  # Format for wofi with image
      else
        printf '%s\n' "$rel"
      fi
    done \
  | wofi --show dmenu --allow-images --sort-order=alphabetical --insensitive --prompt "Choose Wallpaper Set"
)"


[ -z "$choice" ] && exit 1  # Exit if no selection
choice="${choice#*text:}"  # Remove wofi formatting if present
realpath "$wallpaper_dir/$choice"  # Output absolute path to selected set
