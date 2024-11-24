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
  customStyle = builtins.readFile ./styles/custom.css;
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
      ++ lib.optionals config.${namespace}.desktop.wms.sway.enable [
        "sway/workspaces"
        "sway/mode"
      ]
      ++ [ "custom/separator-left" ]
      ++ lib.optionals config.${namespace}.desktop.wms.sway.enable [ "sway/window" ];
  };

  fullSizeModules = {
    modules-right =
      [
        # "custom/separator-right"
        "group/stats"
        "custom/separator-right"
        "group/tidbits"
        "group/tray"
        "group/gamma"
        "custom/separator-right"
      ]
      ++ [
        "custom/weather"
        "clock"
      ];
  };

  condensedModules = {
    modules-right =
      [
        # "group/tray-drawer"
        "group/stats-drawer"
        "custom/separator-right"
        # "group/control-center"
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
    systemd.user.services.waybar.Service.ExecStart = mkIf cfg.debug (
      mkForce "${getExe pkgs.waybar} -l debug"
    );

    home.packages = with pkgs; [ custom.waybar-vpn-status ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = mkMerge [
        (generateOutputSettings cfg.fullSizeOutputs "fullSize")
        (generateOutputSettings cfg.condensedOutputs "condensed")
      ];

      style = "${style}${customStyle}${statsStyle}${workspacesStyle}";
    };
  };
}
