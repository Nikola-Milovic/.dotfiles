# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## MANDATORY RULES

**DO NOT MAKE ANY CHANGES without googling first. Every change has to be confirmed that it's actually correct.**

Before making any Nix configuration changes, you MUST search:
- **NixOS options**: https://search.nixos.org/options?channel=25.05&from=0&size=50&sort=relevance&type=packages&query=[your-search]
- **Home Manager options**: https://home-manager-options.extranix.com/?query=[your-search]&release=release-25.05
- **NixOS Wiki**: For additional context and examples

If you cannot find the information needed, tell the user to google for you and paste the results.

## Repository Overview

This is a NixOS configuration repository using flakes and the Snowfall Lib framework. It implements an impermanence setup where the root filesystem is wiped on every boot, with only `/nix`, `/boot`, and `/persist` being retained.

## Common Development Commands

### System Rebuilding
- `nh os switch` - Rebuild and switch to new NixOS configuration
- `nh os boot` - Rebuild and set as boot configuration  
- `nh os test` - Test configuration without switching

### Development Environments
- `nix develop .#nix` - Enter Nix development shell (includes nixfmt-rfc-style, nixd, sops)
- `nix develop .#go` - Enter Go development shell
- `nix develop .#lua` - Enter Lua development shell

### Code Formatting
- `nix fmt` - Format all Nix files using nixfmt-rfc-style

### Custom Packages
- `nix run .#backup` - Backup /persist directory to ~/backup/backups/linux/
- `nix run .#monitor-control` - Control monitor brightness/contrast
- `nix run .#gammastep-helper` - Adjust screen temperature
- `nix run .#waybar-vpn-status` - Check VPN status

## Architecture

### Module System
The repository uses Snowfall Lib with a custom namespace. All modules are prefixed with `custom.`:
- `modules/nixos/` - System-level NixOS modules
- `modules/home/` - Home-manager modules  
- `modules/shared/` - Shared modules between home and system
- `systems/` - Host-specific configurations (workstation, vm)
- `homes/` - User@host specific home configurations

### Impermanence
**Critical**: The system uses impermanence - changes outside `/persist` are lost on reboot.
- Persistent data lives in `/persist/` and is bind-mounted to expected locations
- User data persists at `/persist/home/nikola/`
- To persist new files/directories, add them to:
  - System: `modules/nixos/system/impermanence/default.nix`
  - User: `modules/home/impermanence/default.nix`
  - Application-specific: In the relevant module

### Secret Management
Uses SOPS with age encryption:
- Secrets are in `secrets/` directory
- Configuration in `.sops.yaml`
- Access secrets in Nix with `config.sops.secrets.<name>`

## Important Notes

1. **Never disable impermanence** - The system is designed around this feature
2. **All custom modules use the `custom` namespace** - e.g., `custom.programs.neovim`
3. **Test changes with `nh os test`** before switching
4. **Backup /persist before major changes** using `nix run .#backup`
5. **BTRFS subvolumes**: root (ephemeral), nix, persist, log, swap
6. **Main branch is `master`**, not `main`

## Hardware Context
- AMD Ryzen 9 9950X with 64GB RAM
- AMD GPU (ROCm support configured)
- Kinesis Advantage 2 keyboard with custom Dvorak layout
- Sway/Wayland desktop environment