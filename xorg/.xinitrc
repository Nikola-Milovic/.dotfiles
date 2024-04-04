#!/bin/sh
# ~/.xinitrc

# Set the session type to X11
export XDG_SESSION_TYPE=x11

# Set the GNOME Shell session mode to i3
export GNOME_SHELL_SESSION_MODE=i3

# Run the system xinitrc scripts (if any)
if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

# Start the compositor (xcompmgr)
xcompmgr &

# Set the keyboard layout to real-prog-dvorak
setxkbmap real-prog-dvorak

# Start the i3 window manager
i3
