# .dotfiles

My personal NixOS flake. Built on [snowfall-lib](https://github.com/snowfallorg/lib),
hardened with [impermanence](https://github.com/nix-community/impermanence), and
secured with [sops-nix](https://github.com/Mic92/sops-nix). It's my daily driver.

Ported from my previous Ubuntu setup at
[.dotfiles-old](https://github.com/Nikola-Milovic/.dotfiles-old).

## What's in here

- **NixOS** with a **Sway / Wayland** desktop session
- **Impermanent root**: only `/nix`, `/boot`, and `/persist` survive a reboot;
  everything else is wiped on every boot and explicitly opted in for persistence
- **SOPS + age** for secrets, scoped per host
- **Custom xkb layouts** alongside stock dvorak, plumbed through to sway
  keybindings so layout changes propagate automatically
- **Per-arch hosts** for Linux and (in progress) Darwin

## Repository layout

The `custom.` namespace is reserved for everything defined in this repo,
following snowfall conventions.

| Path             | Purpose                                                    |
| ---------------- | ---------------------------------------------------------- |
| `flake.nix`      | Flake entry point and inputs                               |
| `systems/`       | Per-host NixOS / nix-darwin configurations                 |
| `homes/`         | Per-user home-manager configurations (`<arch>/<user>...`)  |
| `modules/nixos/` | System-level NixOS modules                                 |
| `modules/home/`  | home-manager modules                                       |
| `modules/shared/`| Modules shared between system and home                     |
| `lib/`           | Snowfall library extensions exposed under `lib.custom.*`   |
| `packages/`      | Custom packages, surfaced as flake outputs                 |
| `overlays/`      | Nixpkgs overlays (`brave`, `calibre`, `unstable-pkgs`)     |
| `shells/`        | Per-language `nix develop` shells                          |
| `secrets/`       | SOPS-encrypted secrets (see `.sops.yaml`)                  |

### Hosts

- `systems/x86_64-linux/workstation` — main desktop
- `systems/x86_64-linux/vm` — virtualised test target
- `systems/aarch64-darwin/macbook` — work in progress (see `plans/darwin.md`)

## Common commands

Rebuild the system (using [`nh`](https://github.com/viperML/nh)):

```sh
nh os switch     # rebuild and switch
nh os boot       # rebuild and set as the next boot generation
nh os test       # rebuild without switching (ephemeral, recommended for trying changes)
```

Drop into a development shell:

```sh
nix develop .#nix    # nixfmt-rfc-style, nixd, sops
nix develop .#go
nix develop .#lua
```

Run a custom package:

```sh
nix run .#backup              # back up /persist to ~/backup/backups/linux/
nix run .#monitor-control     # monitor brightness / contrast
nix run .#gammastep-helper    # screen colour temperature
nix run .#waybar-vpn-status   # waybar VPN module
nix run .#networkmon          # network monitor
```

Format every Nix file in the tree:

```sh
nix fmt
```

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

Clone this repo and switch to the Darwin branch:

```sh
mkdir -p ~/code
cd ~/code
git clone https://github.com/Nikola-Milovic/.dotfiles.git
cd .dotfiles
git switch darwin-macbook
```

Install the MacBook age key before activating SOPS-backed Home Manager:

```sh
mkdir -p ~/.config/sops/age
install -m 600 ~/Downloads/macbook-keys.txt ~/.config/sops/age/keys.txt
```

Before `just` is installed, use it through Nix:

```sh
nix run nixpkgs#just -- darwin-check
nix run nixpkgs#just -- darwin-bootstrap
```

After the first successful activation:

```sh
just darwin-check
just darwin-switch
```

The standalone Home Manager helpers are available too:

```sh
nix run nixpkgs#just -- hm-bootstrap
just hm-switch
```

## Impermanence

The root filesystem is reset on every boot. To keep state across reboots, opt in
explicitly. This is Linux/NixOS-only; the Darwin configuration does not use
impermanence.

- System state → `modules/nixos/system/impermanence/default.nix`
- User state → `modules/home/impermanence/default.nix`
- App-specific state → the relevant module's own impermanence block

Persistent data lives under `/persist/...` and is bind-mounted back to where
the app expects it. Before any major change, snapshot it:

```sh
nix run .#backup
```

## Credits

Heavy inspiration (and outright borrowed patterns) from:

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
