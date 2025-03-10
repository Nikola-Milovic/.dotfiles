{
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkForce;
  inherit (lib.${namespace}) enabled;
in
{
  imports = [ ./hardware-configuration.nix ];

  # --------------

  custom = {
    system = {
      general = {
        gcRetentionDays = "3d";
      };

      keyboard.real-prog-dvorak = true;

      fonts = enabled;
      impermanence = {
        enable = true;
      };

      disko.btrfs = {
        enable = true;
        swapSize = "2G";
        device = "/dev/sda2";
      };
    };

    programs.nh = enabled;

    security = {
      keyring = enabled;
      polkit = enabled;
    };

    desktop = {
      displaymanager.tuigreet = enabled;
      wms.sway = enabled;
    };

    services = {
      ssh = enabled;
      docker = enabled;
    };

    user = {
      hashedPassword = "$6$lP/WAcHvSHwBHxMn$ou44X10FVP3kHaTrIBSpwZGA0jlf5YSLp2lha9fSeJcOLaw5lvWD9BuH3lyNs3qlASqfe/TVtDSkpj5PzpWJK1";
      fullName = "Nikola Milovic";
      extraGroups = [
        "wheel"
        "video"
      ];
    };

    hardware = {
      networking = enabled;
      audio = enabled;
    };
  };
}
