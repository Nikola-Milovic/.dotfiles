set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

home := "nikola"
darwin_host := "macbook"

default:
    @just --list

# Evaluate the standalone Home Manager activation derivation.
hm-eval home=home:
    nix eval .#homeConfigurations."{{home}}".activationPackage.drvPath

# Bootstrap Home Manager before the home-manager command exists.
hm-bootstrap home=home:
    nix run github:nix-community/home-manager/release-25.11 -- switch --flake .#{{home}}

# Switch standalone Home Manager after it has been bootstrapped.
hm-switch home=home:
    home-manager switch --flake .#{{home}}

# Evaluate the nix-darwin system derivation.
darwin-eval host=darwin_host:
    nix eval .#darwinConfigurations.{{host}}.config.system.build.toplevel.drvPath

# Bootstrap nix-darwin before the darwin-rebuild command exists.
darwin-bootstrap host=darwin_host:
    nix run github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#{{host}}

# Switch nix-darwin after it has been bootstrapped.
darwin-switch host=darwin_host:
    darwin-rebuild switch --flake .#{{host}}

# Evaluate the MacBook Home Manager and nix-darwin targets.
darwin-check: hm-eval darwin-eval

# Evaluate existing Linux Home Manager targets.
linux-home-check:
    nix eval .#homeConfigurations."nikola@workstation".activationPackage.drvPath
    nix eval .#homeConfigurations."nikola@vm".activationPackage.drvPath
