# .dotfiles

A collection of my .dotfiles, still a work in progress as I migrate my work environment to a more customizable experience.

## Set kitty as default terminal

```
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which kitty` 50
sudo update-alternatives --config x-terminal-emulator
```

## sway

`sudo update-alternatives --config x-window-manager`

## Keyboard

[real-prog-dvorak github](https://github.com/ThePrimeagen/keyboards/tree/master/ubuntu)

We have to add the keyboard to here and also add an entry into the rules (rules might be unnecessary on Wayland)

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

## Cool tools

Cool alternatives to common Unix commands like `grep`, `find`, `top`... (mostly written in Rust)

Mostly trying them out and playing around with my setup

- `ripgrep` - search tool [github.com/BurntSushi/ripgrep](github.com/BurntSushi/ripgrep)
- `fd` - simple and fast alternative to `find` [github.com/shardp/fd](github.com/shardp/fd)
- `bottom` - graphical process/system monitor [github.com/ClementTsang/bottom](github.com/ClementTsang/bottom)
- `sd` - intuitive find & replace [https://github.com/chmln/sd](https://github.com/chmln/sd)
- `procs` - modern replacement for `ps` [https://github.com/dalance/procs](https://github.com/dalance/procs)
- `exa` - modern replacement for `ls` [https://github.com/ogham/exa](https://github.com/ogham/exa)
- `bat` - a cat(1) clone [https://github.com/sharkdp/bat](https://github.com/sharkdp/bat)
- `hyperfine` - CLI benchmarking tool [https://github.com/sharkdp/hyperfine](https://github.com/sharkdp/hyperfine)
- `tokei` - count code, file lines... [https://github.com/XAMPPRocky/tokei](https://github.com/XAMPPRocky/tokei)
- `dust` - modern replacement for `du` [https://github.com/bootandy/dust](https://github.com/bootandy/dust)
- `broot` - new way to see and navigate directory trees [https://github.com/Canop/broot](https://github.com/Canop/broot)
- `atuin` - magical shell history [https://github.com/ellie/atuin](https://github.com/ellie/atuin) (requires additional [setup for bash](https://atuin.sh/docs/advanced-install#bash))
- `starship.rs` - cross-shell prompt [https://github.com/starship/starship](https://github.com/starship/starship)

## Themes

Kitty and Neovim use [`tokyonight`](https://github.com/folke/tokyonight.nvim)

### Font 

`JetBrains Mono Nerd Font`

1. Add `.ttf`'s to `/usr/local/share/fonts` 
1. Run `fc-cache -f -v`

## System miscellaneous 

### Bluetooth 
https://askubuntu.com/questions/1423752/ubuntu-20-04-unable-to-use-a-bluetooth-dongle-tp-link-ub500

### Darkmode

`exec --no-startup-id /usr/libexec/gsd-xsettings`

`//dark
alias dark='gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark \
&& gsettings set org.gnome.desktop.interface color-scheme prefer-dark'`

### Sound

set default sink with pulse audio

`/etc/pulse/default.pa`

### SSH && mosh
port forward from X port to 2222 in router for SSH
port forward from 60001 to any in router for mosh
also enable firewall these connections in firewall

## TODOS

- [ ] worktree

Good to haves

- [ ] Add installs for dependencies - ansible 
- [ ] Look into NixOS 

#### Low priority

- terminal browser
