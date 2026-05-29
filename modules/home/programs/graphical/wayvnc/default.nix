{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.graphical.wayvnc;
in
{
  options.${namespace}.programs.graphical.wayvnc = {
    enable = mkEnableOption "wayvnc";
  };

  config = lib.mkIf cfg.enable { home.packages = [ pkgs.wayvnc ]; };
}
