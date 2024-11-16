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
        config = {
          common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];

        # https://github.com/NixOS/nixpkgs/pull/179204 	
        # gtkUsePortal = true;
      };
    };
  };
}
