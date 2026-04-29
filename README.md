# .dotfiles

Personal NixOS and macOS configuration flake. Built on
[snowfall-lib](https://github.com/snowfallorg/lib), with
[home-manager](https://github.com/nix-community/home-manager),
[nix-darwin](https://github.com/nix-darwin/nix-darwin), NixOS
[impermanence](https://github.com/nix-community/impermanence), and
[sops-nix](https://github.com/Mic92/sops-nix).

Ported from my previous Ubuntu setup at
[.dotfiles-old](https://github.com/Nikola-Milovic/.dotfiles-old).

## What's In Here

- **NixOS workstation** with Sway / Wayland
- **Impermanent NixOS root**: only `/nix`, `/boot`, and `/persist` survive reboots
- **Apple Silicon MacBook** managed with nix-darwin and Home Manager
- **SOPS + age** for secrets, scoped per host
- **Custom xkb layouts** on Linux, plumbed through to Sway keybindings
- **Darwin keyboard defaults** for Dvorak, Caps Lock, and non-US tilde behavior
- **Homebrew-managed macOS apps** through the Darwin layer

## Repository Layout

Everything defined by this repo uses the `custom.` namespace.

| Path              | Purpose                                                   |
| ----------------- | --------------------------------------------------------- |
| `flake.nix`       | Flake entry point and inputs                              |
| `systems/`        | Per-host NixOS / nix-darwin configurations                |
| `homes/`          | Per-user Home Manager configurations                      |
| `modules/nixos/`  | NixOS system modules                                      |
| `modules/darwin/` | nix-darwin system and app modules                         |
| `modules/home/`   | Home Manager modules                                      |
| `modules/shared/` | Modules shared between system and home                    |
| `lib/`            | Snowfall library extensions exposed under `lib.custom.*`  |
| `packages/`       | Custom packages surfaced as flake outputs                 |
| `overlays/`       | nixpkgs overlays                                          |
| `shells/`         | Per-language `nix develop` shells                         |
| `secrets/`        | SOPS-encrypted secrets                                    |

## Hosts

- `systems/x86_64-linux/workstation` - main NixOS desktop
- `systems/x86_64-linux/vm` - virtualized test target
- `systems/aarch64-darwin/macbook` - Apple Silicon MacBook

## Common Commands

Use `just` as the normal entry point:

```sh
just switch          # Darwin: HM then sudo darwin-rebuild; Linux: sudo nixos-rebuild
just hm-switch       # standalone Home Manager switch
just darwin-switch   # sudo darwin-rebuild for macbook
just nixos-switch    # sudo nixos-rebuild for workstation
```

Development shells:

```sh
nix develop .#nix
nix develop .#go
nix develop .#lua
```

Run custom packages:

```sh
nix run .#backup
nix run .#monitor-control
nix run .#gammastep-helper
nix run .#waybar-vpn-status
nix run .#networkmon
```

Format the tree:

```sh
nix fmt
```

## macOS Package Policy

The rule for Darwin is:

- **CLI tools**: use nixpkgs, Home Manager, flake inputs, overlays, or local packages.
- **GUI apps and macOS app bundles**: use nix-darwin-managed Homebrew, with nix-homebrew as the preferred bootstrap layer if Homebrew ownership needs to be made fully declarative.

This keeps the Mac simple and reliable. Even if a nixpkgs package exposes a
`.app`, pinning that app into the Dock can leave a missing question mark after
rebuilds because the Dock points at an old store path. Use Homebrew casks for
apps that live in `/Applications`.

Current examples:

- `ghostty` and `wezterm` are Homebrew casks in `modules/darwin/apps/terminals/default.nix`
- `worktrunk` is a Homebrew formula on macOS
- `worktrunk` is installed from its upstream Nix flake on Linux

## Darwin MacBook

Install Nix on a clean macOS machine:

```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

Restart the terminal, then enable flakes for bootstrap:

```sh
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf
```

Clone this repo:

```sh
mkdir -p ~/Desktop
cd ~/Desktop
git clone https://github.com/Nikola-Milovic/.dotfiles.git dotfiles
cd dotfiles
```

Install the MacBook age key before activating SOPS-backed Home Manager:

```sh
mkdir -p ~/.config/sops/age
install -m 600 ~/Downloads/macbook-keys.txt ~/.config/sops/age/keys.txt
```

Bootstrap with `just` through Nix:

```sh
nix run nixpkgs#just -- switch
```

After the first successful activation:

```sh
just switch
```

`darwin-rebuild switch` must run as root. The `just` recipes already do that
with `sudo`.

## Impermanence

The NixOS root filesystem is reset on every boot. To keep state across reboots,
opt in explicitly:

- System state: `modules/nixos/system/impermanence/default.nix`
- User state: `modules/home/impermanence/default.nix`
- App-specific state: the relevant module's own impermanence block

Persistent data lives under `/persist/...` and is mounted back to where apps
expect it. Before major changes, snapshot it:

```sh
nix run .#backup
```

Darwin does not use impermanence.

## Credits

Heavy inspiration and borrowed patterns from:

- [jakehamilton/config](https://github.com/jakehamilton/config)
- [khaneliman/khanelinix](https://github.com/khaneliman/khanelinix)
- [hmajid2301/nixicle](https://github.com/hmajid2301/nixicle)
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)

## TODO

- [ ] Security enhancements
- [ ] Evaluate [Looking Glass](https://looking-glass.io/) as an alternative to dual-booting
- [ ] [YubiKey](https://github.com/drduh/YubiKey-Guide) setup
- [ ] Fix sway brightness hotkeys
- [ ] Wrong audio device picked as default
- [ ] BTRFS rollback not working
