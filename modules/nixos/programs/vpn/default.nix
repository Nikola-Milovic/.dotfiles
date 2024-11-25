{
  options,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) types mkEnableOption mkIf;
  cfg = config.${namespace}.programs.vpn;
in
{
  options.${namespace}.programs.vpn = with types; {
    enable = mkEnableOption "vpn";
  };

  config = mkIf cfg.enable {
    # sudo nmcli connection import type openvpn file
    networking.networkmanager.plugins = [ pkgs.gnome.networkmanager-openvpn ];

    # users.users.${config.${namespace}.user.name}.packages = [ pkgs.cloudflare-warp ];

    # TODO: [24.11] https://discourse.nixos.org/t/cant-start-cloudflare-warp-cli/232674
    # services.cloudflare-warp = {
    # 	enable = true;
    # };

    # programs.openvpn3.enable = true;
  };
}
