{
  options,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.${namespace}.programs.graphical.obsidian;
in
{
  options.${namespace}.programs.graphical.obsidian = with types; {
    enable = mkEnableOption "obsidian";
  };

  config = mkIf cfg.enable { home.packages = [ pkgs.obsidian ]; };
}
