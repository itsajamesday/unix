#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#  for f in /etc/X11/xinit/xinitrc.d/*; do
#    [ -x "$f" ] && . "$f"
#  done
#  unset f
#fi


setxkbmap -layout gb
xsetroot -cursor_name left_ptr
eval $(gpg-agent --daemon)
#xautolock -time 10 -locker ~/.local/bin/lockscreen &
xrdb -merge ~/.xdefaults
nitrogen --restore
xset +fp ${HOME}/.fonts
xset fp rehash
#xrandr --output DFP10 --auto --primary
#xrandr --output DFP11 --auto --right-of DFP10
hsetroot -center ~/.config/bspwm/Wallpaper.jpg
sxhkd &
mxset +fp ~/.fonts
mxset fp rehash
exec bspwm
compton &
