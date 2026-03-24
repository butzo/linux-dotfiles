# ~/.profile
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
  if uwsm check may-start; then
    exec uwsm start hyprland.desktop
  fi
fi


export BROWSER=brave
export TERM=alacritty
export QT_QPA_PLATFORMTHEME="qt5ct"

