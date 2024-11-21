{
  options,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) types mkEnableOption mkIf;
  cfg = config.${namespace}.programs.terminal.devenv;
in
{
  options.${namespace}.programs.terminal.devenv = with types; {
    enable = mkEnableOption "devenv";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.devenv ];

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
