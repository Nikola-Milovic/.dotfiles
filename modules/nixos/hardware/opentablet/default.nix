{ lib, namespace, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.${namespace}.hardware.opentablet;
in
{
  options.${namespace}.hardware.opentablet = {
    enable = lib.mkEnableOption "support for opentablet";
  };

  config = mkIf cfg.enable {
    hardware.opentabletdriver.enable = true;
  };
}
