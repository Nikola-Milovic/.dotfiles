{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    types
    mkIf
    mkForce
    ;
  inherit (lib.${namespace}) mkOpt;
  cfg = config.${namespace}.system.general;
in
{
  options.${namespace}.system.general = with types; {
    gcRetentionDays = mkOpt str "3d" "How many days of GC-able data to retain";
    maxJobs = mkOpt int 0 "Max jobs to allow nix";
    cores = mkOpt int 0 "Number of logical cores the system has";
  };

  config = {
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.emergencyAccess = true;
    boot.initrd.supportedFilesystems = mkIf config.${namespace}.system.disko.btrfs.enable (mkForce [
      "btrfs"
    ]);
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

    nix.gc = mkIf (config.${namespace}.programs.nh.enable == false) {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than ${cfg.gcRetentionDays}";
    };

    nix.settings = {
      cores = cfg.cores;
      max-jobs = if cfg.maxJobs > 0 then cfg.maxJobs else "auto";
    };

    services.xserver.displayManager.lightdm.enable = mkForce false;
  };
}
