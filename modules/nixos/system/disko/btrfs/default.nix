# If you'd saved this configuration in ./disks/default.nix, and wanted to create a disk named /dev/nvme0n1, you would run the following command to partition, format and mount the disk.
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disks/default.nix --arg device '"/dev/nvme0n1"'

{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.disko.btrfs;
in
{
  options.${namespace}.system.disko.btrfs = with types; {
    enable = mkEnableOption "BTFRS Filesystem";
    device = mkOpt str "" "Which device to target";
    swapSize = mkOpt str "" "The size of the swap";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.device != "";
        message = "config.system.disko.btrfs.device is not set!";
      }
      {
        assertion = cfg.swapSize != "";
        message = "config.system.disko.btrfs.swapSize is not set!";
      }
    ];

    disko.devices = {
      disk = {
        nvme0n1 = {
          type = "disk";
          device = cfg.device;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                label = "boot";
                name = "ESP";
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "defaults" ];
                };
              };
              root = {
                size = "100%";
                label = "nixos-root";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "subvol=root"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "subvol=home"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "subvol=nix"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "subvol=persist"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "subvol=log"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = cfg.swapSize;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
