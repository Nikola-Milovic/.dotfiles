#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)

# invoke global X session script
. /etc/X11/Xsession
# export XDG_SESSION_TYPE=x11
# exec gnome-session
# exec i3
export XDG_SESSION_TYPE=x11
export GNOME_SHELL_SESSION_MODE=i3

# Start the GNOME + i3 session
exec gnome-session --session=i3-gnome
