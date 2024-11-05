{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.${namespace}) mkBoolOpt;
  cfg = config.${namespace}.programs.graphical.desktop.addons.wallpapers;
  inherit (pkgs.custom) wallpapers;
in
{
  options.${namespace}.programs.graphical.desktop.addons.wallpapers = with types; {
    enable = mkBoolOpt false "Whether or not to add wallpapers to ~/Pictures/wallpapers.";
  };

  config = mkIf cfg.enable ({
    home.file = lib.foldl (
      acc: name:
      let
        wallpaper = wallpapers.${name};
      in
      acc // { "Pictures/wallpapers/${wallpaper.fileName}".source = wallpaper; }
    ) { } (wallpapers.names);
  });
}
