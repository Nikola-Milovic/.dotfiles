set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

home := "nikola"
darwin_host := "macbook"
nixos_host := "workstation"

hm := "github:nix-community/home-manager/release-25.11"
darwin_rebuild := "github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild"
nixos_rebuild := "github:NixOS/nixpkgs/nixos-25.11#nixos-rebuild"

default:
    @printf '%s\n' 'switch' 'hm-switch' 'darwin-switch' 'nixos-switch'

switch:
    case "$(uname -s)" in \
      Darwin) \
        nix run {{hm}} -- switch --flake .#{{home}}; \
        nix run {{darwin_rebuild}} -- switch --flake .#{{darwin_host}}; \
        ;; \
      Linux) \
        sudo nix run {{nixos_rebuild}} -- switch --flake .#{{nixos_host}}; \
        ;; \
      *) \
        echo "Unsupported system: $(uname -s)" >&2; \
        exit 1; \
        ;; \
    esac

hm-switch home=home:
    nix run {{hm}} -- switch --flake .#{{home}}

darwin-switch host=darwin_host:
    nix run {{darwin_rebuild}} -- switch --flake .#{{host}}

nixos-switch host=nixos_host:
    sudo nix run {{nixos_rebuild}} -- switch --flake .#{{host}}
