{
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
{
  imports = [ ./hardware-configuration.nix ];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;
  boot.initrd.supportedFilesystems = mkForce [ "btrfs" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.05";

  system = {
    impermanence = enabled;
    disko.btrfs = {
      enable = true;
      swapSize = "2G";
      device = "/dev/sda2";
    };
  };

  services = {
    ssh = enabled;
  };

  users = {
    mutableUsers = false;

    users = {
      root.hashedPassword = "$6$SS1zHvFP7bqY6yqo$g3R63sGjSlt8dAZh.oGznVg90GtSciNJDZU.BXb2SrVi.qHjnfcuiYRzwKdEoFq/gpJmQOWQ7Gr7ZVELKKXcr.";

      nikola = {
        hashedPassword = "$6$lP/WAcHvSHwBHxMn$ou44X10FVP3kHaTrIBSpwZGA0jlf5YSLp2lha9fSeJcOLaw5lvWD9BuH3lyNs3qlASqfe/TVtDSkpj5PzpWJK1";
        isNormalUser = true;
        home = "/home/nikola";
        description = "Nikola Milovic";
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
        ];
      };
    };
  };

  # Mount a VirtualBox shared folder.
  # This is configurable in the VirtualBox menu at
  # Machine / Settings / Shared Folders.
  # fileSystems."/mnt" = {
  #   fsType = "vboxsf";
  #   device = "nameofdevicetomount";
  #   options = [ "rw" ];
  # };

  # By default, the NixOS VirtualBox demo image includes SDDM and Plasma.
  # If you prefer another desktop manager or display manager, you may want
  # to disable the default.
  services.xserver.desktopManager.plasma5.enable = lib.mkForce false;
  # services.displayManager.sddm.enable = lib.mkForce false;

  # Enable GDM/GNOME by uncommenting above two lines and two lines below.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

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

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };

  # docker
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  xdg.portal.wlr.enable = true;

  security.rtkit.enable = true;

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  #services.pipewire = {
  #	enable = true;
  #	alsa.enable = true;
  #	alsa.support32Bit = true;
  #	pulse.enable = true;
  #	# If you want to use JACK applications, uncomment this
  #	#jack.enable = true;
  #};
  #
  #hardware.pulseadio.enable = false;

  # List packages installed in system profile. To search, run:
  # \$ nix search wget
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    wget
    vim
    foot
    git
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
