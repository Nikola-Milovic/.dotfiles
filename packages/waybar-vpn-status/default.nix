{
  pkgs,
  stdenv,
  lib,
}:

pkgs.writeShellApplication {
  name = "waybar-vpn-status";

  runtimeInputs = [ pkgs.networkmanager ];

  meta = with pkgs.lib; {
    description = "Script to return JSON formatted VPN and Tunnel status";
    mainProgram = "waybar-vpn-status";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };

  checkPhase = "";

  text = ''
    # Check for active WARP connection
    WARP_STATUS=$(nmcli con show --active | ( grep "WARP" || true))

    # Check for active VPN connection and extract the VPN name
    VPN_NAME=$(nmcli con show --active | ( grep "vpn" || true) | awk '{print $1}')

    # Determine the status and output the appropriate JSON
    if [[ -n "$WARP_STATUS" ]]; then
    	echo -n "{\"text\":\"WARP\",\"class\":\"connected\",\"icon\":\"󱠾\"}"
    elif [[ -n "$VPN_NAME" ]]; then
    	echo -n "{\"text\":\"''${VPN_NAME}\",\"class\":\"connected\",\"icon\":\"\"}"
    else
    	echo -n "{\"text\":\"NO VPN\",\"class\":\"disconnected\",\"icon\":\"󱦄\"}"
    fi
  '';
}
