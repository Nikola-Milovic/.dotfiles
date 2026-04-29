# AGENTS.md

Guidance for Codex when working in this repository.

## Mandatory Rules

- Before changing Nix, Home Manager, or nix-darwin configuration, verify option and package names against current upstream docs or local evaluated options. This repo currently tracks `25.11`, so use 25.11 option/package references unless the flake inputs say otherwise.
- Prefer official or primary sources for Nix behavior: NixOS options/package search, Home Manager options, nix-darwin options, upstream module source, or the package's own repository/docs.
- Keep changes scoped. Do not refactor modules, rename hosts, or move package ownership unless the user asked for it.
- Never disable impermanence on NixOS.
- Preserve the `custom` namespace for repo-defined modules and options.

## Repository Overview

This is a personal flake using Snowfall Lib. It manages:

- NixOS hosts with Home Manager and impermanence
- An Apple Silicon MacBook with nix-darwin and Home Manager
- Shared terminal, development, theme, and app modules under the `custom` namespace
- SOPS/age secrets

The NixOS root filesystem is wiped on every boot. Only explicitly persisted state survives.

## Package Policy

### Linux / NixOS

- Use nixpkgs, flake inputs, overlays, or local packages for CLI and GUI software.
- Keep persistent app state declared through the impermanence modules.

### macOS / Darwin

- Use nixpkgs/Home Manager for CLI tools, shell integrations, development tools, and portable terminal packages.
- Use nix-darwin-managed Homebrew for GUI apps, casks, and macOS app bundles. If Homebrew bootstrap ownership is needed, use a nix-homebrew-backed Darwin module rather than imperative setup.
- Do not install Dock/Applications GUI apps from nixpkgs `.app` bundles unless there is a specific reason. Rebuilds can leave Dock entries pointing at stale store paths, which show as missing question marks and need repinning.
- Add macOS GUI apps under `modules/darwin/apps/*`, not under generic Home Manager package lists.
- `worktrunk` is intentionally split: Linux gets the upstream Nix flake package, macOS gets the Homebrew formula.

## Common Commands

Use the `justfile` recipes as the main entry points:

```sh
just switch          # Darwin: Home Manager then sudo darwin-rebuild; Linux: sudo nixos-rebuild
just hm-switch       # standalone Home Manager profile
just darwin-switch   # sudo darwin-rebuild for macbook
just nixos-switch    # sudo nixos-rebuild for workstation
```

Development shells:

```sh
nix develop .#nix
nix develop .#go
nix develop .#lua
```

Formatting:

```sh
nix fmt
```

Custom package entry points:

```sh
nix run .#backup
nix run .#monitor-control
nix run .#gammastep-helper
nix run .#waybar-vpn-status
nix run .#networkmon
```

## Architecture

The repo uses Snowfall Lib with the `custom` namespace.

- `systems/x86_64-linux/workstation` - main NixOS desktop
- `systems/x86_64-linux/vm` - virtualized NixOS test target
- `systems/aarch64-darwin/macbook` - Apple Silicon macOS target
- `homes/x86_64-linux/nikola@workstation` - workstation Home Manager profile
- `homes/x86_64-linux/nikola@vm` - VM Home Manager profile
- `homes/aarch64-darwin/nikola` - MacBook Home Manager profile
- `modules/nixos/` - NixOS system modules
- `modules/darwin/` - nix-darwin system and app modules
- `modules/home/` - Home Manager modules
- `modules/shared/` - shared system/home modules
- `packages/` - local flake packages
- `overlays/` - nixpkgs overlays
- `shells/` - development shells

## Impermanence

NixOS uses impermanence. Changes outside `/persist`, `/nix`, and `/boot` are not durable.

- System persistence: `modules/nixos/system/impermanence/default.nix`
- User persistence: `modules/home/impermanence/default.nix`
- App-specific persistence: the relevant module

Back up persistent state before risky changes:

```sh
nix run .#backup
```

macOS does not use impermanence.

## Darwin Notes

- `darwin-rebuild switch` must run as root; use `just switch` or `just darwin-switch`.
- The existing macOS user must be in `users.knownUsers` with the correct `uid` if nix-darwin should update account properties such as `UserShell`.
- The MacBook shell is managed as `pkgs.bashInteractive`; Home Manager owns the bash aliases, starship integration, and terminal init.
- Keyboard settings are managed in `modules/darwin/system/keyboard/default.nix`; the MacBook enables Dvorak, Caps Lock to Control, and non-US tilde remapping.
- GUI app additions should go through Darwin/Homebrew modules, not generic Home Manager packages.

## Secrets

Secrets use SOPS with age encryption:

- Encrypted files live under `secrets/`
- SOPS config is in `.sops.yaml`
- Access secrets in Nix with `config.sops.secrets.<name>`

## Hardware Context

Linux workstation:

- AMD Ryzen 9 9950X with 64GB RAM
- AMD GPU with ROCm support
- Kinesis Advantage 2 keyboard with custom Dvorak layout
- Sway/Wayland desktop

Darwin:

- Apple Silicon MacBook
- Ghostty/WezTerm through Homebrew casks
- Dvorak-oriented keyboard setup

## Git

- Main branch is `master`.
- Do not revert user changes unless explicitly asked.
