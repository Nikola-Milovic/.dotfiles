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
  cfg = config.${namespace}.programs.graphical.desktop.addons.wofi;
in
{
  options.${namespace}.programs.graphical.desktop.addons.wofi = with types; {
    enable = mkEnableOption "Wofi launcher";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wofi
      wofi-emoji
    ];

    custom.programs.graphical.desktop.wms.sway.launcherCmd = "${
      pkgs.wofi.pname or pkgs.wofi.name
    } --show drun --prompt search";

    # config -> .config/wofi/config
    # css -> .config/wofi/style.css
    # colors -> $XDG_CACHE_HOME/wal/colors
    # custom.home.configFile."foot/foot.ini".source = ./foot.ini;
    xdg.configFile."wofi/config".source = ./config;
    xdg.configFile."wofi/style.css".source = ./style.css;
  };
}
