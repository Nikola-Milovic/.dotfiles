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
  cfg = config.${namespace}.desktop.addons.foot;
in
{
  options.${namespace}.desktop.addons.foot = with types; {
    enable = mkEnableOption "foot terminal";
  };

  config = mkIf cfg.enable {
    custom.desktop.wms.sway.term = pkgs.foot;

    # TODO: https://unix.stackexchange.com/a/348796
    dconf.settings = {
      "org.cinnamon.desktop.default-applications.terminal" = {
        exec = "foot";
      };
      "org.gnome.desktop.default-applications.terminal" = {
        exec = "foot";
      };
    };

    home.packages = [ pkgs.foot ];

    xdg.configFile."foot/foot.ini".source = ./foot.ini;
  };
}
