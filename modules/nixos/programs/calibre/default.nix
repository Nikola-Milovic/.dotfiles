{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.calibre;
in
{
  options.${namespace}.programs.calibre = {
    enable = mkEnableOption "calibre";
  };

  config = lib.mkIf cfg.enable {
    ${namespace}.system.impermanence.userDirectories = [ ".config/calibre" ];
    environment.systemPackages = with pkgs; [ (calibre.override { unrarSupport = true; }) ];
    services.udisks2.enable = true;
  };
}
