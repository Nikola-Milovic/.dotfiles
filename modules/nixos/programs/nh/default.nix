{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.nh;
in
{
  options.${namespace}.programs.nh = {
    enable = mkEnableOption "yet another nix helper (nh)";
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since ${config.${namespace}.system.general.gcRetentionDays} --keep 3";
      flake = "/home/${config.${namespace}.user.name}/.dotfiles";
    };
  };
}
