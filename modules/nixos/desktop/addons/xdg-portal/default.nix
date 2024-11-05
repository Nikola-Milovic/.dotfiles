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
  cfg = config.${namespace}.desktop.addons.xdg-portal;
in
{
  options.${namespace}.desktop.addons.xdg-portal = with types; {
    enable = mkEnableOption "xdg portal";
  };

  config = mkIf cfg.enable {
    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
        gtkUsePortal = true;
      };
    };
  };
}
