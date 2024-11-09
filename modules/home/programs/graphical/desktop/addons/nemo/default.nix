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
  cfg = config.${namespace}.programs.graphical.desktop.addons.nemo;
in
{
  options.${namespace}.programs.graphical.desktop.addons.nemo = with types; {
    enable = mkEnableOption "Nemo file manager";
  };

  config = mkIf cfg.enable {
    custom.programs.graphical.desktop.wms.sway.filemanager = pkgs.cinnamon.nemo;
    home.packages = with pkgs; [ cinnamon.nemo ];
  };
}
