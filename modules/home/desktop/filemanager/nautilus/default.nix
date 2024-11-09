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
  cfg = config.${namespace}.desktop.filemanager.nautilus;
in
{
  options.${namespace}.desktop.filemanager.nautilus = with types; {
    enable = mkEnableOption "Gnome file manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gnome.nautilus ];

    custom.desktop.wms.sway.filemanager = pkgs.gnome.nautilus;
  };
}
