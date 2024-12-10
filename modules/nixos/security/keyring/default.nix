{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.security.keyring;
in
{
  options.${namespace}.security.keyring = {
    enable = mkEnableOption "gnome keyring";
  };

  config = mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    environment.systemPackages = with pkgs; [
      libgnome-keyring
      gnome-keyring
    ];
  };
}
