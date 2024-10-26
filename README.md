# .dotfiles

A collection of my .dotfiles, still a work in progress as I migrate my work environment to a more customizable experience.

## Setup 

`make setup/laptop|work|desktop`

## Terminal

I've since switched to `wezterm` from `kitty`, its written in Rust and I am trying to have my entire system in Rust, soontm.

Jokes aside, I just wanted to try something new, `wezterm` seems easy to configure, performs well, and I don't really use any of the features of my terminal since I have other tools for that. And the `kitty` maintainer usually has more dislikes than likes on his responses which just threw me off every time I was reading about an issue.

```
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which wezterm` 50
sudo update-alternatives --config x-terminal-emulator
```

## Enviroment

Since I use multiple devices, personal and for work, I needed a way to switch between these. So for now there are symlinks for sway and git configs that are included by the common main config. So I just just swap out the include for any environment specific configuration

## Keyboard

[real-prog-dvorak github](https://github.com/ThePrimeagen/keyboards/tree/master/ubuntu)

We have to add the keyboard to here and also add an entry into the rules (rules might be unnecessary on Wayland)

```
sudo cp real-prog-dvorak /usr/share/X11/xkb/symbols/
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

## Clipboard (Wayland)

For clipboard install `ws-clipboard`

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

## DNS

Change DNS from ISP to Cloudflare

### Firefox

[Install via apt not snap](https://askubuntu.com/a/1404401/1106437)

## Apps
*Regular*

```
brave, stow, sway, swaylock, waybar, pavlucontrol, obsidian, wezterm, neovim, ripgrep, fd-find, mosh, git, wl-clipboard, ripgrep
```

*~/bin binaries*
````
atuin bat broot dust exa fzf hyperfine lazygit localstack open-wezterm-here procs starship strip-ansi-escapes tldr tokei wezterm wezterm-gui wezterm-mux-server zellij zoxide
````
# Security
## VPN

[Setup VPN to only be working for specified route](https://weiguangcui.github.io/2020-10-07-route-VPN-to-specific-ips/) (home PC)

## Cloudflare

### SSH with Cloudflare

On server run the cloudflared tunnel 
```terminal
docker run --add-host=host.docker.internal:host-gateway -d --name sshtunnel cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhxxxxxxxxxxx
```

On host machine follow the [Connect to SSH server with cloudflared access guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/#connect-to-ssh-server-with-cloudflared-access)

## Display manager 

[ly](https://github.com/fairyglade/ly), display manager with console ui, simple and works for Wayland and Xorg

## Screenshots (Wayland)

[`grim`](https://sr.ht/~emersion/grim/) + [`slurp`](https://github.com/emersion/slurp)

## Issues

1. `libssl.1.1` not found when running `wezterm` 
[Solution](https://gist.github.com/joulgs/c8a85bb462f48ffc2044dd878ecaa786)


## X11

`~/.xinitrc` sets up gnome keyring and i3
```bash
#!/bin/sh

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

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

# Set the keyboard layout to real-prog-dvorak
setxkbmap real-prog-dvorak

# Start the i3 window manager
i3
```

## TODOS

- [ ] worktree

Good to haves

- [ ] Add installs for dependencies - ansible 
- [ ] Look into NixOS 
