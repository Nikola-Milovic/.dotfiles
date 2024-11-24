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
  cfg = config.${namespace}.desktop.addons.gammastep;
in
{
  options.${namespace}.desktop.addons.gammastep = with types; {
    enable = mkEnableOption "gammastep";
  };

  config = mkIf cfg.enable { home.packages = [ pkgs.wl-gammarelay-rs ]; };
}
