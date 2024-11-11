{
  config,
  inputs,
  lib,
  pkgs,
  system,
  namespace,
  osConfig,
  ...
}:
let
  inherit (lib)
    mkIf
    mkForce
    getExe
    mkMerge
    mkEnableOption
    types
    ;
  inherit (lib.${namespace}) mkOpt mkBoolOpt;

  cfg = config.${namespace}.desktop.bars.waybar;

  style = builtins.readFile ./styles/style.css;
  controlCenterStyle = builtins.readFile ./styles/control-center.css;
  powerStyle = builtins.readFile ./styles/power.css;
  statsStyle = builtins.readFile ./styles/stats.css;
  workspacesStyle = builtins.readFile ./styles/workspaces.css;

  custom-modules = import ./modules/custom-modules.nix { inherit config lib pkgs; };
  default-modules = import ./modules/default-modules.nix { inherit lib pkgs; };
  group-modules = import ./modules/group-modules.nix { inherit lib namespace osConfig; };
  sway-modules = import ./modules/sway-modules.nix { inherit config lib; };

  commonAttributes = {
    layer = "top";
    position = "bottom";

    margin-top = 10;
    margin-left = 20;
    margin-right = 20;

    modules-left =
      [ "custom/wlogout" ]
      ++ lib.optionals config.${namespace}.desktop.wms.sway.enable [ "sway/workspaces" ]
      ++ [ "custom/separator-left" ]
      ++ lib.optionals config.${namespace}.desktop.wms.sway.enable [ "sway/window" ];
  };

  fullSizeModules = {
    modules-right =
      [
        "group/tray"
        "custom/separator-right"
        "group/stats"
        "custom/separator-right"
        "group/control-center"
      ]
      ++ [
        # "custom/weather"
        "clock"
      ];
  };

  condensedModules = {
    modules-right =
      [
        "group/tray-drawer"
        "group/stats-drawer"
        "group/control-center"
      ]
      ++ [
        # "custom/weather"
        "clock"
      ];
  };

  mkBarSettings =
    barType:
    mkMerge [
      commonAttributes
      (if barType == "fullSize" then fullSizeModules else condensedModules)
      custom-modules
      default-modules
      group-modules
      (lib.mkIf config.${namespace}.desktop.wms.sway.enable sway-modules)
    ];

  generateOutputSettings =
    outputList: barType:
    builtins.listToAttrs (
      builtins.map (outputName: {
        name = outputName;
        value = mkMerge [
          (mkBarSettings barType)
          { output = outputName; }
        ];
      }) outputList
    );
in
{
  options.${namespace}.desktop.bars.waybar = {
    enable = mkEnableOption "waybar";
    debug = mkBoolOpt false "Whether to enable debug mode.";
    fullSizeOutputs =
      mkOpt (types.listOf types.str) "Which outputs to use the full size waybar on."
        [ ];
    condensedOutputs =
      mkOpt (types.listOf types.str) "Which outputs to use the smaller size waybar on."
        [ ];
  };

  config = mkIf cfg.enable {
    # systemd.user.services.waybar.Service.ExecStart = mkIf cfg.debug (
    #   mkForce "${getExe pkgs.waybar} -l debug"
    # );

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = mkMerge [
        (generateOutputSettings cfg.fullSizeOutputs "fullSize")
        (generateOutputSettings cfg.condensedOutputs "condensed")
      ];

      style = "${style}${controlCenterStyle}${powerStyle}${statsStyle}${workspacesStyle}";
    };

    # sops.secrets = lib.mkIf osConfig.${namespace}.security.sops.enable {
    #   weather_config = {
    #     sopsFile = lib.snowfall.fs.get-file "secrets/nikola/default.yaml";
    #     path = "${config.home.homeDirectory}/weather_config.json";
    #   };
    # };
  };
}

#     home.packages = with pkgs; [
#       (pkgs.writeTextFile {
#         name = "waybar_network_status";
#         destination = "/bin/waybar_network_status.sh";
#         executable = true;
#         text = ''
#           #! ${pkgs.bash}/bin/bash
#           # Consolidated script for VPN and WARP status and toggle actions for Waybar
#
#           case "$1" in
#             vpn-status)
#               VPN_STATUS=$(nmcli con show --active | grep "vpn")
#               if [[ -z "$VPN_STATUS" ]]; then
#                 echo -n "{\"text\":\"NO VPN\",\"class\":\"disconnected\",\"icon\":\"🔴\"}"
#               else
#                 VPN_NAME=$(echo "$VPN_STATUS" | awk '{print $1}')
#                 echo -n "{\"text\":\"$VPN_NAME\",\"class\":\"connected\",\"icon\":\"🟢\"}"
#               fi
#               ;;
#
#             vpn-toggle)
#               VPN_NAME=$(nmcli con show --active | grep "vpn" | awk '{print $1}')
#               if [[ ! -z "$VPN_NAME" ]]; then
#                 nmcli con down id "$VPN_NAME"
#               else
#                 nmcli con up id "my_vpn"  # Replace 'my_vpn' with your actual VPN name
#               fi
#               ;;
#
#             warp-status)
#               WARP_STATUS=$(nmcli con show --active | grep "WARP")
#               if [[ -z "$WARP_STATUS" ]]; then
#                 echo -n "{\"text\":\"| NO WARP |\",\"class\":\"disconnected\",\"icon\":\"🔴\"}"
#               else
#                 echo -n "{\"text\":\"| WARP |\",\"class\":\"connected\",\"icon\":\"🟢\"}"
#               fi
#               ;;
#
#             warp-toggle)
#               WARP_STATUS=$(nmcli con show --active | grep "WARP")
#               if [[ -z "$WARP_STATUS" ]]; then
#                 warp-cli connect
#               else
#                 warp-cli disconnect
#               fi
#               ;;
#
#             *)
#               echo "Usage: $0 [vpn-status | vpn-toggle | warp-status | warp-toggle]"
#               exit 1
#               ;;
#           esac
#         '';
#       })
#     ];
