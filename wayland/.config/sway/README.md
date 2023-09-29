# /etc/ly/wsetupsh

#!/bin/bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export CLUTTER_BACKEND=wayland
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland-egl
export QT_WAYLAND_FORCE_DPI=physical
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export MOZ_WEBRENDER=1

# [ "$(tty)" = "/dev/tty1" ] && exec sway
exec sway
