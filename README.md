# .dotfiles

A collection of my .dotfiles, still a work in progress as I migrate my work environment to a more customizable experience.

## Set kitty as default terminal

```
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which kitty` 50
sudo update-alternatives --config x-terminal-emulator
```

## Keyboard

https://github.com/ThePrimeagen/keyboards/tree/master/ubuntu

We have to add the keyboard to here and also add an entry into the rules

```
sudo cp ~/dotfiles/xkb/.config/xkb/real-prog-dvorak /usr/share/X11/xkb/symbols/
```

```
[rwin]>[lwin]
[end]>[lctrl]
[lalt]>[end]
[pdown]>[lalt]
[rctrl]>[pup]
[lctrl]>[pdown]
[pup]>[tab]
```

## Sound

set default sink with pulse audio

`/etc/pulse/default.pa`

## TODOS

[] Lazygit open and edit files
[] Add installs for dependencies - golang - i3blocks - python - chromium - kitty - godot - discord
[] worktree
[] harpoon in monorepo
