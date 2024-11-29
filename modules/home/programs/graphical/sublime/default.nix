{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.graphical.sublime;
in
{
  options.${namespace}.programs.graphical.sublime = {
    enable = mkEnableOption "sublime";
  };

  config = lib.mkIf cfg.enable { home.packages = [ pkgs.sublime4 ]; };
}
