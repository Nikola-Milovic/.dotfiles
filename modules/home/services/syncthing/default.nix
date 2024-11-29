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
  homeDir = ".local/state/syncthing";
in
{
  options.${namespace}.services.syncthing = with types; {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence.directories = [ homeDir ];

    services.syncthing = {
      enable = true;
      extraOptions = [
        "--no-default-folder"
        "--home=${homeDir}"
      ];
    };
  };
}
