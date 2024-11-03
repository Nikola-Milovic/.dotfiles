{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.impermanence;
in
{
  options.${namespace}.system.impermanence = with types; {
    enable = mkBoolOpt false "Whether or not to enable impermanence.";
    # TODO: home impermanence
    home = mkBoolOpt false "Whether or not to enable impermanence for /home as well.";
  };

  config = mkIf cfg.enable {
    security.sudo.extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';

    programs.fuse.userAllowOther = true;

    boot.initrd.systemd.services.rollback = {
      description = "Simplified Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [ "initrd.target" ];
      before = [
        "initrd-root-fs.target"
        "sysroot-var-lib-nixos.mount"
      ];
      after = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /btrfs_tmp
        mount /dev/sda2 -o subvol=/ /btrfs_tmp

        # Backup and rotate the /root subvolume
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        # Function to recursively delete old subvolumes
        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        # Remove /root backups older than 14 days
        find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +14 -exec bash -c 'delete_subvolume_recursively "$0"' {} \;

        # Create a fresh /root subvolume
        btrfs subvolume create /btrfs_tmp/root
        echo "Created fresh /root subvolume"

        # Optionally backup and rotate the /home subvolume if enabled
        ${optionalString cfg.home ''
          if [[ -e /btrfs_tmp/home ]]; then
              mkdir -p /btrfs_tmp/old_home
              timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/home)" "+%Y-%m-%-d_%H:%M:%S")
              mv /btrfs_tmp/home "/btrfs_tmp/old_home/$timestamp"
          fi

          # Remove /home backups older than 14 days
          find /btrfs_tmp/old_home/ -maxdepth 1 -mtime +14 -exec bash -c 'delete_subvolume_recursively "$0"' {} \;

          # Create a fresh /home subvolume
          btrfs subvolume create /btrfs_tmp/home
          echo "Created fresh /home subvolume"
        ''}

        # Unmount /btrfs_tmp after completing operations
        umount /btrfs_tmp
      '';
    };

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/srv"
        "/.cache/nix/"
        "/etc/NetworkManager/system-connections"
        "/var/cache/"
        "/var/tmp/" # needed because we change the nix tmp dir to /var/tmp
        "/var/db/sudo/"
        "/var/lib/"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };

    fileSystems."/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
  };
}
