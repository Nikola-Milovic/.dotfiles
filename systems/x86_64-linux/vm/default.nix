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

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;
  boot.initrd.supportedFilesystems = mkForce [ "btrfs" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://github.com/NixOS/nixpkgs/pull/338181#issuecomment-2344510691
  boot = {
    tmp.useTmpfs = true;
  };
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  system.stateVersion = "24.05";

  users = {
    mutableUsers = false;

    users = {
      root.hashedPassword = "$6$SS1zHvFP7bqY6yqo$g3R63sGjSlt8dAZh.oGznVg90GtSciNJDZU.BXb2SrVi.qHjnfcuiYRzwKdEoFq/gpJmQOWQ7Gr7ZVELKKXcr.";
    };
  };

  time.timeZone = "Europe/Belgrade";

  services.xserver = {
    xkb.extraLayouts.real-prog-dvorak = {
      description = "Real programmers dvorak";
      languages = [ "eng" ];
      symbolsFile = lib.snowfall.fs.get-file "/configs/keyboard/real-prog-dvorak";
    };

    enable = true;

    xkb.layout = "us";
    xkb.variant = "dvorak";
  };
  console.useXkbConfig = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    wget
    vim
    git
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  nix.settings = {
    cores = 4;
    max-jobs = 4;
  };

  services.xserver.displayManager.lightdm.enable = mkForce false;

  # --------------

  custom = {
    system = {
      fonts = enabled;
      impermanence = {
        enable = true;
        home = false;
      };
      disko.btrfs = {
        enable = true;
        swapSize = "2G";
        device = "/dev/sda2";
      };
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
