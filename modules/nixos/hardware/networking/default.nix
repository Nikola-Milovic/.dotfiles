{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.hardware.networking;
in
{
  options.${namespace}.hardware.networking = with types; {
    enable = mkEnableOption "Networking";
    hosts = mkOpt attrs { } (mdDoc "An attribute set to merge with `networking.hosts`");
  };

  config = mkIf cfg.enable {
    custom.user.extraGroups = [ "networkmanager" ];

    environment.etc.hosts.mode = "0644";

    networking = {
      firewall = {
        enable = true;
      };

      nameservers = mkForce [
        "1.1.1.1"
        "9.9.9.9"
        "8.8.8.8"
      ];

      hosts = {
        "127.0.0.1" = [ "local.test" ] ++ (cfg.hosts."127.0.0.1" or [ ]);
      }
      // cfg.hosts;

      networkmanager = {
        enable = true;
        dhcp = "internal";

        # Try and solve the issue of NM attaching the router as the default NS
        dns = "none";
        settings = {
          main = {
            rc-manager = "unmanaged";
          };
        };
      };
    };

    # Fixes an issue that normally causes nixos-rebuild to fail.
    # https://github.com/NixOS/nixpkgs/issues/180175
    # systemd.services.NetworkManager-wait-online.enable = true;
  };
}
