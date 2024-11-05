{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption types mkIf;
  cfg = config.${namespace}.programs.graphical.desktop.addons.nautilus;
in
{
  options.${namespace}.programs.graphical.desktop.addons.nautilus = with types; {
    enable = mkEnableOption "Gnome file manager";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ gnome.nautilus ]; };
}
