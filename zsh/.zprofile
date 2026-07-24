# ~/.zprofile
#if [ -f ~/.profile ]; then
#  emulate -L sh
#  . ~/.profile
#fi
# Only run Hyprland autostart on tty1 and only if no compositor is active yet

if [ "$(tty)" = "/dev/tty1" ] && [ -f ~/.no-next-autostart ] && uwsm check may-start >/dev/null 2>&1; then

	rm -f ~/.no-next-autostart

elif [ "$(tty)" = "/dev/tty1" ] && [ ! -f ~/.no-autostart ] && uwsm check may-start >/dev/null 2>&1; then

	exec uwsm start hyprland.desktop

fi
