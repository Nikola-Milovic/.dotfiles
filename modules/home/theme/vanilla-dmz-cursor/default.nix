{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkForce;

  cfg = config.${namespace}.theme.vanilla-dmz-cursor;
in
{
  options.${namespace}.theme.vanilla-dmz-cursor = {
    enable = mkEnableOption "vanilla dmz cursor";
  };

  config = lib.mkIf cfg.enable {
    # home.file.".icons/vanilla-dmz".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
    ${namespace}.theme.gtk.cursor = mkForce {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };
  };
}
