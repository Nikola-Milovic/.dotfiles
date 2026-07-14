{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.programs.graphical.aseprite;
in
{
  options.${namespace}.programs.graphical.aseprite = {
    enable = mkEnableOption "Aseprite";
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence.directories = [ ".config/aseprite" ];

    home.packages = [ pkgs.aseprite ];
  };
}
