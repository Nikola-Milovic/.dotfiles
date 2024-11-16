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
    mkEnableOption
    types
    ;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;
  cfg = config.${namespace}.system.impermanence;
in
{
  options.${namespace}.system.impermanence = with types; {
    enable = mkEnableOption "Impermanence";
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

        			if [[ -e /btrfs_tmp/root ]]; then
        					mkdir -p /btrfs_tmp/old_roots
        					timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        					mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        			fi

        			delete_subvolume_recursively() {
        					IFS=$'\n'
        					for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
        							delete_subvolume_recursively "/btrfs_tmp/$i"
        					done
        					btrfs subvolume delete "$1"
        			}

        			for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +14); do
        					delete_subvolume_recursively "$i"
        			done

        			btrfs subvolume create /btrfs_tmp/root
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
      users.${config.${namespace}.user.name} = {
        directories = [ ".dotfiles" ];
      };
    };

    fileSystems."/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
  };
}
