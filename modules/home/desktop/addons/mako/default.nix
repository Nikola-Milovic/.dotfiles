{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.desktop.addons.mako;

  # Catppuccin Macchiato colors
  colors = {
    base = "#24273a";
    surface0 = "#363a4f";
    text = "#cad3f5";
    blue = "#8aadf4";
    lavender = "#b7bdf8";
    peach = "#f5a97f";
    red = "#ed8796";
  };
in
{
  options.${namespace}.desktop.addons.mako = {
    enable = mkEnableOption "mako notification daemon";
  };

  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      settings = {
        # General settings
        font = "JetBrainsMono Nerd Font 11";
        width = 350;
        height = 150;
        margin = "10";
        padding = "15";
        border-size = 2;
        border-radius = 8;
        max-icon-size = 48;
        icon-location = "left";
        max-visible = 5;
        layer = "overlay";
        anchor = "top-right";

        # Timing
        default-timeout = 5000;
        ignore-timeout = 0;

        # Colors (Catppuccin Macchiato)
        background-color = colors.base;
        text-color = colors.text;
        border-color = colors.lavender;
        progress-color = "over ${colors.surface0}";

        # Urgency-specific styling (criteria without brackets)
        "urgency=low" = {
          border-color = colors.blue;
          default-timeout = 3000;
        };

        "urgency=normal" = {
          border-color = colors.lavender;
        };

        "urgency=high" = {
          border-color = colors.peach;
          default-timeout = 10000;
        };

        "urgency=critical" = {
          border-color = colors.red;
          default-timeout = 0;
        };
      };
    };
  };
}
