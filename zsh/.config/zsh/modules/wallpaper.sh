#!/bin/sh
# Wallpaper helpers around ~/.config/wallpaper/.current_wallpaper, a symlink
# pointing at the active image file.
load-wallpaper() {
    # current_wallpaper: global alias, expands anywhere on the command line,
    # e.g. `feh current_wallpaper` or `cp current_wallpaper ~/pics/`.
    alias -g current_wallpaper='$HOME/.config/wallpaper/.current_wallpaper'

    # disable-wallpaper: rename the real current wallpaper file to *.disabled.
    alias disable-wallpaper='mv "$(realpath ~/.config/wallpaper/.current_wallpaper)" "$(realpath ~/.config/wallpaper/.current_wallpaper)".disabled'

    # move-wallpaper <dir>: move the current wallpaper's real file into <dir>.
    move-wallpaper() {
        local dest="$1"
        if [ -z "$dest" ] || [ ! -d "$dest" ]; then
            echo "move-wallpaper: '$dest' is not a directory" >&2
            return 1
        fi
        local real
        real="$(realpath ~/.config/wallpaper/.current_wallpaper)" || return 1
        mv "$real" "$dest"
    }
}
