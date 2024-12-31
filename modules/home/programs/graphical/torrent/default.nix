{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.graphical.torrent;
in
{
  options.${namespace}.programs.graphical.torrent = {
    enable = mkEnableOption "transmission torrent client";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.transmission_4-gtk
    ];
  };
}
