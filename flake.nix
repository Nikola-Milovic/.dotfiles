{
  description = "NixOS system setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    disko.url = "github:nix-community/disko";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		catppuccin-cursors.url = "github:catppuccin/cursors";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    impermanence.url = "github:nix-community/impermanence";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { ... }@inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          meta = {
            name = "dotfiles";
            title = "Dotfiles";
          };

          namespace = "custom";
        };
      };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      homes.modules = with inputs; [
        impermanence.homeManagerModules.default
        catppuccin.homeManagerModules.catppuccin
        sops-nix.homeManagerModules.sops
      ];

      systems.modules = {
        nixos = with inputs; [
          disko.nixosModules.disko
          impermanence.nixosModule
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
        ];
      };

      outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; };
    };
}
