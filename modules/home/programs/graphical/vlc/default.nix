{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.graphical.vlc;
in
{
  options.${namespace}.programs.graphical.vlc = {
    enable = mkEnableOption "vlc";
  };

  config = lib.mkIf cfg.enable { home.packages = [ pkgs.vlc ]; };
}
