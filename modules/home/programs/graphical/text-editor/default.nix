{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.programs.graphical.text-editor;
in
{
  options.${namespace}.programs.graphical.text-editor = {
    enable = mkEnableOption "GNOME Text Editor";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.gnome-text-editor ];

    xdg.mimeApps = {
      enable = true;
      defaultApplicationPackages = [ pkgs.gnome-text-editor ];
    };
  };
}
