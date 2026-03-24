#!/bin/bash

if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
fi


awww img --transition-duration 0.1 .config/wallpaper/.current_wallpaper