{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.system.nix;
in
{
  options.${namespace}.system.nix = {
    enable = mkBoolOpt false "Whether to manage nix-darwin Nix settings.";
    trustedUsers = mkOpt (types.listOf types.str) [
      "@admin"
      config.system.primaryUser
    ] "Users allowed to perform trusted Nix operations.";
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nix;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = cfg.trustedUsers;
        substituters = [
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      nixfmt-rfc-style
    ];
  };
}
