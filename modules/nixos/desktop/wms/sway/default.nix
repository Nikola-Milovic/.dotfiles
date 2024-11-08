{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf getExe mkEnableOption;
  inherit (lib.${namespace}) enabled;

  cfg = config.${namespace}.desktop.wms.sway;
in
{
  options.${namespace}.desktop.wms.sway = {
    enable = mkEnableOption "Sway";
  };

  config = mkIf cfg.enable {
    custom.desktop.addons.xdg-portal = enabled;

    services.xserver.enable = true;
    services.libinput.enable = true;
  };
}
