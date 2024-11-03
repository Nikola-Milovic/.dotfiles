{
  lib,
  config,
  namespace,
  ...
}:
let
  inherit (lib)
    mkIf
    optionalString
    mkMerge
    types
    ;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;
  cfg = config.${namespace}.system.impermanence;
in
{
  options.${namespace}.system.impermanence = with types; {
    enable = mkBoolOpt false "Whether or not to enable impermanence.";
    home = mkBoolOpt false "Whether or not to enable impermanence for /home as well.";
    files = mkOpt (listOf (either str attrs)) [ ] "Additional files to persist.";
    directories = mkOpt (listOf (either str attrs)) [ ] "Additional directories to persist.";
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


        # Function to recursively delete old subvolumes
        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        # Backup and rotate the /root subvolume
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        # Remove /root backups older than 14 days
        for backup in /btrfs_tmp/old_roots/*; do
            if [[ -d "$backup" && $(find "$backup" -maxdepth 0 -mtime +14) ]]; then
                delete_subvolume_recursively "$backup"
            fi
        done

        # Create a fresh /root subvolume
        btrfs subvolume create /btrfs_tmp/root
        echo "Created fresh /root subvolume"

        # Optionally backup and rotate the /home subvolume if enabled
        ${optionalString cfg.home ''
                if [[ -e /btrfs_tmp/home ]]; then
          					echo "Backing up current home"
                    mkdir -p /btrfs_tmp/old_home
                    timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/home)" "+%Y-%m-%-d_%H:%M:%S")
                    mv /btrfs_tmp/home "/btrfs_tmp/old_home/$timestamp"
                fi

                # Remove /home backups older than 14 days
                for backup in /btrfs_tmp/old_home/*; do
                    if [[ -d "$backup" && $(find "$backup" -maxdepth 0 -mtime +14) ]]; then
          						  echo "Removing old home backups $backup"
                        delete_subvolume_recursively "$backup"
                    fi
                done

                # Create a fresh /home subvolume
                btrfs subvolume create /btrfs_tmp/home
                echo "Created fresh /home subvolume"


          			mkdir -p /btrfs_tmp/home/${config.${namespace}.user.name}
          			# we have to use the hardcoded ID of the user since it's too early in the boot process
          			chown 1000 /btrfs_tmp/home/${config.${namespace}.user.name}

          			echo "Created /home/${config.${namespace}.user.name}"

                # Ensure user home directory exists in /persist
                if [[ ! -e /btrfs_tmp/persist/home/${config.${namespace}.user.name} ]]; then
                    mkdir -p /btrfs_tmp/persist/home/${config.${namespace}.user.name}
                    chown 1000 /btrfs_tmp/persist/home/${config.${namespace}.user.name}
                fi
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
      ] ++ cfg.directories;
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ] ++ cfg.files;
    };

    fileSystems."/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
  };
}
