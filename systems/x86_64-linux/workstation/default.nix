{
  inputs,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkForce;
  inherit (lib.${namespace})
    disabled
    enabled
    ;
in
{
  imports = [ ./hardware-configuration.nix ];

  # Temporary pin for shutdown regression: Linux 7.0.x reaches systemd poweroff
  # but leaves the machine physically powered on, while 6.19.10 powers off cleanly.
  boot.kernelPackages =
    inputs.nixpkgs-kernel-619.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_6_19;

  # --------------
  custom = {
    virtualisation.kvm = enabled;
    system = {
      general = {
        gcRetentionDays = "3d";
      };

      keyboard.layout = "dvorak";

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
      mkcert = enabled;
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
      networkmon = disabled;
      ollama = {
        enable = true;
        acceleration = "rocm";
        rocmOverrideGfx = "11.0.0"; # RX 7000 series
        loadModels = [ "llama3.2:3b" ];
      };
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
      opentablet = enabled;
      cpu.amd = enabled;
      opengl = enabled;
      networking = enabled;
      audio = enabled;
      i2c = enabled;
    };
  };
}
