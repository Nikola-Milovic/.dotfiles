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
    custom = {
      desktop.addons.xdg-portal = enabled;
    };

		programs.sway = enabled;

    services.xserver = enabled;
    services.libinput = enabled;
  };
}
