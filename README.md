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
[caps]>[escape]
```

## Darkmode

`exec --no-startup-id /usr/libexec/gsd-xsettings`

`//dark
alias dark='gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark \
&& gsettings set org.gnome.desktop.interface color-scheme prefer-dark'`

## Sound

set default sink with pulse audio

`/etc/pulse/default.pa`

## Styling

## Themes

Kitty and Neovim use [`tokyonight`](https://github.com/folke/tokyonight.nvim)

### Font 

`JetBrains Mono Nerd Font`

1. Add `.ttf`'s to `/usr/local/share/fonts` 
1. Run `fc-cache -f -v`

## Bluetooth 
https://askubuntu.com/questions/1423752/ubuntu-20-04-unable-to-use-a-bluetooth-dongle-tp-link-ub500

## TODOS

- [ ] worktree

Good to haves

- [ ] Add installs for dependencies - ansible 
- [ ] Look into NixOS 



#### Low priority

- terminal browser
