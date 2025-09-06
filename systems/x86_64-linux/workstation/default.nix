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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --------------
  custom = {
    virtualisation.kvm = enabled;
    system = {
      general = {
        gcRetentionDays = "3d";
      };

      keyboard.layout = "lemi-dvorak";

      fonts = enabled;
      # NEVER DISABLE IMPERMANENCE
      impermanence = {
        enable = true;
        device = "/dev/nvme1n1p2";
      };

      disko.btrfs = {
        enable = true;
        swapSize = "64G";
        device = "/dev/nvme0n1";
      };
    };

    programs = {
      nh = enabled;
      vpn = enabled;
      calibre = enabled;
      nix-ld = enabled;
    };

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
      tailscale = enabled;
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
      gpu.amd = {
        enable = true;
        enableRocmSupport = true;
      };
      cpu.amd = enabled;
      opengl = enabled;
      networking = enabled;
      audio = enabled;
      i2c = enabled;
    };
  };
}
