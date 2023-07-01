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

## Cool tools

Cool alternatives to common Unix commands like `grep`, `find`, `top`... (mostly written in Rust)

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


## TODOS

- [ ] worktree

Good to haves

- [ ] Add installs for dependencies - ansible 
- [ ] Look into NixOS 



#### Low priority

- terminal browser
