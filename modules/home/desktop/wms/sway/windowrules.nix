{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.${namespace}.desktop.wms.sway;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      config = {
        assigns = {
          "1" = [ ];

          "4" = [
            { class = "^Brave-browser$"; }
            { class = "^Google Chrome$"; }
            { class = "^firefox$"; }
          ];

          "5" = [
            { app_id = "^Slack$"; }
            { class = "^obsidian$"; }
          ];
        };

        floating = {
          criteria = [
            { class = "Wofi"; }
            { class = "wlogout"; }
            { class = "file_progress"; }
            { class = "confirm"; }
            { class = "dialog"; }
          ];
        };
      };
    };
  };
}
