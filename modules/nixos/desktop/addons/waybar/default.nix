{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.waybar;
in
{
  options.${namespace}.desktop.addons.waybar = with types; {
    enable = mkBoolOpt false "Whether to enable Waybar in the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      waybar
      (pkgs.writeTextFile {
        name = "waybar_network_status";
        destination = "/bin/waybar_network_status.sh";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash
          # Consolidated script for VPN and WARP status and toggle actions for Waybar

          case "$1" in
            vpn-status)
              VPN_STATUS=$(nmcli con show --active | grep "vpn")
              if [[ -z "$VPN_STATUS" ]]; then
                echo -n "{\"text\":\"NO VPN\",\"class\":\"disconnected\",\"icon\":\"🔴\"}"
              else
                VPN_NAME=$(echo "$VPN_STATUS" | awk '{print $1}')
                echo -n "{\"text\":\"$VPN_NAME\",\"class\":\"connected\",\"icon\":\"🟢\"}"
              fi
              ;;
            
            vpn-toggle)
              VPN_NAME=$(nmcli con show --active | grep "vpn" | awk '{print $1}')
              if [[ ! -z "$VPN_NAME" ]]; then
                nmcli con down id "$VPN_NAME"
              else
                nmcli con up id "my_vpn"  # Replace 'my_vpn' with your actual VPN name
              fi
              ;;
            
            warp-status)
              WARP_STATUS=$(nmcli con show --active | grep "WARP")
              if [[ -z "$WARP_STATUS" ]]; then
                echo -n "{\"text\":\"| NO WARP |\",\"class\":\"disconnected\",\"icon\":\"🔴\"}"
              else
                echo -n "{\"text\":\"| WARP |\",\"class\":\"connected\",\"icon\":\"🟢\"}"
              fi
              ;;
            
            warp-toggle)
              WARP_STATUS=$(nmcli con show --active | grep "WARP")
              if [[ -z "$WARP_STATUS" ]]; then
                warp-cli connect
              else
                warp-cli disconnect
              fi
              ;;
            
            *)
              echo "Usage: $0 [vpn-status | vpn-toggle | warp-status | warp-toggle]"
              exit 1
              ;;
          esac
        '';
      })
    ];

    custom.home.configFile."waybar/config".source = ./config;
    custom.home.configFile."waybar/style.css".source = ./style.css;
  };
}
