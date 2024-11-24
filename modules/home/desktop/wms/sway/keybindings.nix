{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    getExe
    getExe'
    mkOptionDefault
    ;
  cfg = config.${namespace}.desktop.wms.sway;

  modifier = config.wayland.windowManager.sway.config.modifier;
  term = config.wayland.windowManager.sway.config.terminal;

  brave = getExe pkgs.brave;
  grim = getExe pkgs.grim;
  slurp = getExe pkgs.slurp;
  wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
  wlogout = getExe pkgs.wlogout;
  chrome = getExe pkgs.google-chrome;
  # Get file manager from config
  filemanager = getExe cfg.filemanager;
  obsidian = getExe pkgs.obsidian;

  pactl = getExe' pkgs.pulseaudio "pactl";
  pavucontrol = getExe pkgs.pavucontrol;
  gammastep = getExe pkgs.wl-gammarelay-rs;
  monitorControl = getExe pkgs.custom.monitor-control;
  busctl = getExe' pkgs.systemd "busctl";

  # Helper functions for `wl-gammarelay`
  increaseTemperature = ''
    ${busctl} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +100
  '';
  decreaseTemperature = ''
    ${busctl} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -100
  '';
  setTemperature = t: "${busctl} --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q ${toString t}";

  increaseBrightness = "${busctl} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.02";
  decreaseBrightness = "${busctl} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.02";
  setBrightness = b: "${busctl} --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d ${toString b}";

  monitorControlCommand =
    {
      brightness ? null,
      contrast ? null,
    }:
    ''
      ${monitorControl} ${if brightness != null then "-b ${toString brightness}" else ""} ${
        if contrast != null then "-c ${toString contrast}" else ""
      }
    '';

  workspace1 = "1";
  workspace2 = "2";
  workspace3 = "3";
  workspace4 = "4";
  workspace5 = "5";
  workspace6 = "6";
  workspace7 = "7";
  workspace8 = "8";
  workspace9 = "9";
  workspace10 = "10";

  volume-mode = "Choose: (1) +5 volume, (2) -5 volume, (3) pavucontrol (4) mute";
  gamma-mode = "Set colour temperature: (a)uto, (r)eset, (1) day, (2) evening, (3) night, (4) very bright day";
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.sway.config = {
      modes = mkOptionDefault {
        "${volume-mode}" = {
          plus = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%, mode \"volume\"";
          bracketleft = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%, mode \"volume\"";
          parenleft = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle, mode \"default\"";
          braceleft = "exec ${pavucontrol}, mode \"default\"";

          # Exit mode
          Return = "mode \"default\"";
          "Ctrl+c" = "mode \"default\"";
          Escape = "mode \"default\"";
        };
        # https://gitlab.com/chinstrap/gammastep/-/issues/41
        "${gamma-mode}" = {
          "1" = "${setTemperature 5000};${setBrightness 0.8},mode \"default\"";
          "2" = "${setTemperature 4000};${setBrightness 0.6},mode \"default\"";
          "3" = "${setTemperature 3000};${setBrightness 0.5},mode \"default\"";
          "4" =  "${setTemperature 7000};${setBrightness 1},mode \"default\"";

          # Exit mode
          Return = "mode \"default\"";
          "Ctrl+c" = "mode \"default\"";
          Escape = "mode \"default\"";
        };
      };
      keybindings =
        with lib;
        mkMerge [
          {
            "${modifier}+Shift+v" = "mode \"${volume-mode}\"";
            "${modifier}+Ctrl+s" = "mode \"${gamma-mode}\"";
          }
          {
            # Application shortcuts
            "${modifier}+Ctrl+b" = "exec ${brave}";
            "${modifier}+Ctrl+m" = "exec ${chrome}";
            "${modifier}+Ctrl+v" = "exec ${filemanager}";
            "${modifier}+Ctrl+a" = "exec ${obsidian}";
            "${modifier}+t" = "exec ${term}";
            "${modifier}+d" = "exec ${cfg.launcherCmd}";

            # Window management
            "${modifier}+Ctrl+q" = "kill";
            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+z" = "split h";
            "${modifier}+v" = "split v";
            "${modifier}+a" = "focus parent";

            "${modifier}+p" = "exec ${grim} -g \"$(${slurp})\" - | ${wl-copy} --type image/png";

            # Focus movement
            "${modifier}+Ctrl+h" = "focus left";
            "${modifier}+Ctrl+j" = "focus down";
            "${modifier}+Ctrl+k" = "focus up";
            "${modifier}+Ctrl+l" = "focus right";

            # Workspace management
            "${modifier}+Ctrl+plus" = "workspace ${workspace1}";
            "${modifier}+Ctrl+bracketleft" = "workspace ${workspace2}";
            "${modifier}+Ctrl+braceleft" = "workspace ${workspace3}";
            "${modifier}+Ctrl+parenleft" = "workspace ${workspace4}";
            "${modifier}+Ctrl+ampersand" = "workspace ${workspace5}";
            "${modifier}+equal" = "workspace ${workspace6}";
            "${modifier}+Ctrl+parenright" = "workspace ${workspace7}";
            "${modifier}+Ctrl+braceright" = "workspace ${workspace8}";
            "${modifier}+bracketright" = "workspace ${workspace9}";
            "${modifier}+Ctrl+asterisk" = "workspace ${workspace10}";

            # Move container to workspace
            "${modifier}+Shift+plus" = "move container to workspace ${workspace1}";
            "${modifier}+Shift+bracketleft" = "move container to workspace ${workspace2}";
            "${modifier}+Shift+braceleft" = "move container to workspace ${workspace3}";
            "${modifier}+Shift+parenleft" = "move container to workspace ${workspace4}";
            "${modifier}+Shift+ampersand" = "move container to workspace ${workspace5}";
            "${modifier}+Shift+equal" = "move container to workspace ${workspace6}";
            "${modifier}+Shift+parenright" = "move container to workspace ${workspace7}";
            "${modifier}+Shift+braceright" = "move container to workspace ${workspace8}";
            "${modifier}+Shift+bracketright" = "move container to workspace ${workspace9}";
            "${modifier}+Shift+asterisk" = "move container to workspace ${workspace10}";

            # Layouts
            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            # Configuration reloads
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";

            # Exit Sway
            "${modifier}+Shift+e" = ''
              exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway?'
            '';

            "${modifier}+Pause" = "${wlogout}";

            # Move workspace between monitors
            "${modifier}+Ctrl+greater" = "move workspace to output right";
            "${modifier}+Ctrl+less" = "move workspace to output left";

            # Workspace back and forth
            "${modifier}+dollar" = "workspace back_and_forth";
          }
        ];
    };
  };
}
