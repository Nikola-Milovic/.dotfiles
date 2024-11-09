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
  cfg = config.${namespace}.desktop.filemanager.nemo;
in
{
  options.${namespace}.desktop.filemanager.nemo = with types; {
    enable = mkEnableOption "Nemo file manager";
  };

  config = mkIf cfg.enable {
    custom.desktop.wms.sway.filemanager = pkgs.cinnamon.nemo;
    home.packages = with pkgs; [ cinnamon.nemo ];
  };
}
