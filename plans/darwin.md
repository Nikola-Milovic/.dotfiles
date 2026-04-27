# Darwin Home Manager Plan

## Goal

Run this repository as standalone Home Manager on macOS first, without requiring a NixOS `osConfig`.
Keep the macOS target conservative: terminal tools and development dependencies first, then add services,
secrets, and GUI apps only after they evaluate and activate cleanly on the Mac.

## Current State

- Existing Linux homes are `homeConfigurations."nikola@workstation"` and `homeConfigurations."nikola@vm"`.
- A new Apple Silicon standalone home has been added at `homes/aarch64-darwin/nikola/default.nix`.
- Snowfall exposes that target as `homeConfigurations."nikola"` in this lock.
- A new nix-darwin target has been started at `systems/aarch64-darwin/macbook/default.nix`.
- Snowfall exposes that target as `darwinConfigurations.macbook`.
- The Darwin home currently enables:
  - `custom.user`
  - `custom.programming`
  - terminal `ssh`, `git`, `starship`, `devenv`, `bash`, `common`, `vim`, and `home-manager`
- The Darwin home deliberately does not enable Linux desktop pieces yet:
  - Sway, Waybar, Foot, Wofi, Wlogout, Mako, Gammastep
  - GTK/Qt desktop theming
  - GNOME keyring
  - Linux-only graphical applications or Wayland flags

## Standalone Fixes Already Applied

- Home modules that consumed `osConfig` now accept `osConfig ? { }` and use safe `lib.attrByPath`
  defaults.
- `custom.impermanence` no longer forces `home.persistence` when the impermanence Home Manager option
  is unavailable. This matters because the current impermanence input expects the NixOS impermanence
  module to auto-import the Home Manager persistence option.
- Home modules that record persistence paths now guard those declarations to Linux. Darwin should not
  use impermanence.
- `custom.user` only configures `xdg.userDirs` on Linux; Home Manager rejects that module on Darwin.
- `custom.user.stateVersion` defaults Home Manager to `24.05`, matching the existing NixOS
  `system.stateVersion`.
- Sway has an explicit `keyboardLayout` option, defaulting from `osConfig` when available and falling
  back to `us` for standalone evaluation.

## macOS Bootstrap

Install Nix in multi-user mode on macOS:

```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

Ensure flakes are enabled if the installer did not already configure them:

```sh
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf
```

Clone this repo, then bootstrap Home Manager from the flake:

```sh
nix run github:nix-community/home-manager/release-25.11 -- switch --flake ~/path/to/.dotfiles#nikola
```

After the first activation, use:

```sh
home-manager switch --flake ~/path/to/.dotfiles#nikola
```

If the Mac is Intel, create a matching `homes/x86_64-darwin/<name>/default.nix` entry or rename the
current Darwin home to a host-specific `nikola@<hostname>` entry.

## Notes From dustinlyons/nixos-config

The useful parts to copy are mostly system-level macOS defaults, not Home Manager packages:

- `system.primaryUser = "<user>";` so nix-darwin can apply user-scoped defaults reliably.
- `system.stateVersion` should be set once and not casually bumped. Dustin's config uses `4`; a new
  nix-darwin install should use the value from the nix-darwin release notes/manual at the time it is
  added.
- `system.defaults.NSGlobalDomain` is useful for:
  - `AppleShowAllExtensions = true`
  - tap-to-click and disabling the alert beep
- Keyboard-specific defaults such as `ApplePressAndHoldEnabled`, `KeyRepeat`, and `InitialKeyRepeat`
  belong in the Darwin keyboard module.
- `system.defaults.dock`, `finder`, and `trackpad` are good candidates once nix-darwin is introduced.
- `nix.settings.trusted-users = [ "@admin" "nikola" ];` is useful in a nix-darwin system config, but
  standalone Home Manager should not manage this.
- `nix-homebrew` is deliberately out of scope for the first pass. The goal is to avoid Brew where Nix
  packages are enough; add it later only for macOS-only casks/apps that are painful or unavailable in
  nixpkgs.
- launchd user agents are worth revisiting for long-running services, but do not copy the Emacs
  example directly unless there is a service we actually want to manage that way.

Do not copy the whole flake shape. This repo already uses Snowfall Lib, so the equivalent layout is:

```text
systems/aarch64-darwin/macbook/default.nix
modules/darwin/system/keyboard/default.nix
modules/darwin/system/defaults/default.nix
modules/darwin/system/nix/default.nix
modules/darwin/home/default.nix
```

Snowfall imports `home-manager.darwinModules.home-manager` automatically for Darwin systems when the
`home-manager` input exists, so this repo only needs the `darwin` input and `modules/darwin/*`.

## Dvorak On macOS

Home Manager alone cannot reliably set the macOS login/session keyboard layout. The initial
nix-darwin target now attempts to configure Dvorak through HIToolbox defaults, plus Caps Lock to
Control through `system.keyboard`.

Minimum manual setup:

1. During macOS setup, choose Dvorak in Keyboard settings if the setup assistant allows it.
2. After login, open System Settings > Keyboard > Text Input > Edit.
3. Add `Dvorak`, make it the active input source, and remove the layout that macOS added by default if
   desired.
4. Optionally remap Caps Lock to Control in System Settings > Keyboard > Keyboard Shortcuts > Modifier
   Keys.

Implemented nix-darwin shape:

```nix
{
  system = {
    primaryUser = "nikola";
    stateVersion = 6;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults.NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };

    defaults.CustomUserPreferences."com.apple.HIToolbox" = {
      AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.Dvorak";
      AppleEnabledInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 16300;
          "KeyboardLayout Name" = "Dvorak";
        }
      ];
      AppleSelectedInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 16300;
          "KeyboardLayout Name" = "Dvorak";
        }
      ];
    };
  };
}
```

Treat the HIToolbox defaults as something to validate on the actual Mac. macOS input-source defaults
have historically been more fragile than Dock/Finder/key-repeat defaults, so the first activation
should be followed by a logout/login and a check at the login screen.

## Migration Order

1. First activation: activate only the current Darwin base home and confirm `$PATH`, shell startup,
   Git, Vim, Starship, Direnv, Devenv, and common CLI tools.
2. Secrets: copy the existing SOPS age key to `~/.config/sops/age/keys.txt`, or create a Mac-specific
   age key, add its recipient to `.sops.yaml`, and rekey `secrets/users/nikola/secrets.yaml`.
3. SSH/Git signing: SOPS is enabled in the Darwin home from the start; verify `github/ssh_pk` and
   commit signing on macOS after activation.
4. Keyboard: decide whether manual Dvorak is enough for first use, or whether nix-darwin should be
   activated before migrating the rest of the machine.
5. Services: test `custom.services.syncthing` on Darwin separately. Home Manager service activation
   differs from Linux because macOS uses launchd, not systemd.
6. GUI apps: evaluate each graphical module on `aarch64-darwin` before enabling:
   - likely candidates: Obsidian, VLC, Sublime
   - needs review: Brave, Cursor, RustDesk, Locallm
   - likely Linux-only or not useful on macOS: Looking Glass, Transmission GTK, Wayland-specific flags
7. README: `dustinlyons/nixos-config` has been added to Inspirations & Credits.

## Verification Commands

From this repo on Linux:

```sh
nix eval .#homeConfigurations."nikola@workstation".activationPackage.drvPath
nix eval .#homeConfigurations."nikola".activationPackage.drvPath
nix eval .#darwinConfigurations.macbook.config.system.build.toplevel.drvPath
```

On macOS:

```sh
nix eval ~/path/to/.dotfiles#homeConfigurations."nikola".activationPackage.drvPath
home-manager switch --flake ~/path/to/.dotfiles#nikola
nix run github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake ~/path/to/.dotfiles#macbook
darwin-rebuild switch --flake ~/path/to/.dotfiles#macbook
```

Do not expect a Linux machine to build the Darwin activation package unless a Darwin builder is
configured. Evaluation is enough to catch most module and package-set mistakes before first activation.

## References

- Nix manual: macOS supports and recommends multi-user Nix installation.
  https://nix.dev/manual/nix/latest/installation/
- Home Manager manual: standalone flake setup is the recommended path when the home should be managed
  independently of NixOS or nix-darwin.
  https://home-manager.dev/manual/23.05/#sec-flakes-standalone
- Snowfall Lib homes: homes live under `homes/<architecture>-<format>/<home-name>/default.nix` and are
  exported through `homeConfigurations`.
  https://snowfall.org/guides/lib/homes/
- dustinlyons/nixos-config Darwin host example.
  https://github.com/dustinlyons/nixos-config/blob/main/hosts/darwin/default.nix
