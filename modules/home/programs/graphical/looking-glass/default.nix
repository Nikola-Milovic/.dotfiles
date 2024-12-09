{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.programs.graphical.looking-glass;
in
{
  options.${namespace}.programs.graphical.looking-glass = {
    enable = mkEnableOption "Looking Glass client.";
  };

  config = mkIf cfg.enable {
    programs.looking-glass-client = {
      enable = true;
      package = pkgs.looking-glass-client;

      settings = {
        input = {
          rawMouse = "yes";
          mouseSens = 6;
          # escapeKey = "";
        };

        spice = {
          enable = true;
          audio = true;
        };

        win = {
          autoResize = "yes";
          quickSplash = "yes";
        };
      };
    };

    # home.packages = with pkgs; [ obs-studio-plugins.looking-glass-obs ];
  };
}
