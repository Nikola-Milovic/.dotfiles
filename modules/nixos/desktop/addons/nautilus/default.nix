{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.nautilus;
in
{
  options.${namespace}.desktop.addons.nautilus = with types; {
    enable = mkBoolOpt false "Whether to enable the gnome file manager.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ gnome.nautilus ]; };
}
