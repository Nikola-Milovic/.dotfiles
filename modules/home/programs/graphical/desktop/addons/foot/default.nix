{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib.${namespace};
let
  inherit (lib) mkEnableOption mkIf types;
  cfg = config.${namespace}.programs.graphical.desktop.addons.foot;
in
{
  options.${namespace}.programs.graphical.desktop.addons.foot = with types; {
    enable = mkEnableOption "foot terminal";
  };

  config = mkIf cfg.enable {
    custom.programs.graphical.desktop.wms.sway.term = pkgs.foot;

    home.packages = [ pkgs.foot ];

    xdg.configFile."foot/foot.ini".source = ./foot.ini;
  };
}
