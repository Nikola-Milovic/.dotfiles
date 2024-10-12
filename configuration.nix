{
  config,
  pkgs,
  lib,
  username,
  nixpkgs,
  system,
  ...
}: {
  imports = [<nixpkgs/nixos/modules/installer/virtualbox-demo.nix>];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Let demo build as a trusted user.
  # nix.settings.trusted-users = [ "demo" ];

  users.users.${username}.extraGroups = ["docker"];
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
      languages = ["eng"];
      symbolsFile = /home/${username}/keyboard/symbols/real-prog-dvorak;
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

  nix.settings.experimental-features = ["nix-command" "flakes"];
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

  # Enable the OpenSSH daemon.
services.openssh = {
  enable = true;
  ports = [ 22 ];
  settings = {
    PasswordAuthentication = true;
    AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
    UseDns = true;
    X11Forwarding = false;
    PermitRootLogin = "yes"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
  };
};}
