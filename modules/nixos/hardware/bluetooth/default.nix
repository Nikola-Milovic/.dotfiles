{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) enabled;

  cfg = config.${namespace}.hardware.bluetooth;
in
{
  options.${namespace}.hardware.bluetooth = {
    enable = mkEnableOption "bluetooth";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;

      package = pkgs.bluez-experimental;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
        };
      };
    };

    boot.kernelParams = [ "btusb" ];

    services.blueman = enabled;
  };
}
