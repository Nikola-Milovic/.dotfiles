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
  inherit (lib.${namespace}) mkOpt;
  cfg = config.${namespace}.programs.graphical.desktop.addons.term;
in
{
  options.${namespace}.programs.graphical.desktop.addons.term = with types; {
    enable = mkEnableOption "Terminal";
    pkg = mkOpt package pkgs.foot "The terminal to install.";
  };

  config = mkIf cfg.enable { home.packages = [ cfg.pkg ]; };
}
