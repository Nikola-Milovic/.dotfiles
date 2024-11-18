{
  options,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.${namespace}.services.syncthing;
in
{
  options.${namespace}.services.syncthing = with types; {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      dataDir = "/home/${config.${namespace}.user.name}/files/syncthing";
    };
  };
}
