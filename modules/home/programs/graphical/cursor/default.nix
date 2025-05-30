{
  options,
  inputs,
  system,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.cursor;
in
{
  options.${namespace}.programs.graphical.cursor = with types; {
    enable = mkBoolOpt false "Enable cursor";
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence.directories = [
      ".cursor"
      ".config/Cursor"
    ];
    home.packages = [ pkgs.appimage-run ];
    programs.bash = {
      shellAliases = {
        c = "clear";
        cursor = "appimage-run ~/files/cursor-latest.AppImage";
      };
    };

  };
}
