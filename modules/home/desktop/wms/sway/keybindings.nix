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

  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  gammastep = "${pkgs.gammastep}/bin/gammastep";
  killgam = "${pkgs.procps}/bin/pkill -x gammastep";
  monitorControl = "${pkgs.${namespace}.monitor-control}/bin/monitor-control";

  workspace1 = "1: IDE";
  workspace2 = "2: terminals";
  workspace3 = "3";
  workspace4 = "4:  ";
  workspace5 = "5: obsidian";
  workspace6 = "6";
  workspace7 = "7";
  workspace8 = "8";
  workspace9 = "9";
  workspace10 = "10";

  volume-mode = "Choose: (1) +5 volume, (2) -5 volume, (3) pavucontrol (4) mute";
  gamma-mode = "Set colour temperature: (a)uto, (r)eset, (1)500K, (2)500K, (3)000K, (4)000K, (5)000K, (6) day";
in
{
  # TODO: https://github.com/Alexays/Waybar/issues/791
  # Sudo to change monitor brightness
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
        "${gamma-mode}" = {
          a = "exec ${killgam}; ${gammastep} -P -t 5000:4000, mode \"default\"";
          r = "exec ${killgam}; ${gammastep} -x; ${monitorControl} -b 50 -c 50, mode \"default\"";
          "1" = "exec ${killgam}; ${gammastep} -P -O 1500; ${monitorControl} -b 0 -c 30, mode \"default\"";
          "2" = "exec ${killgam}; ${gammastep} -P -O 2500; ${monitorControl} -b 15 -c 40, mode \"default\"";
          "3" = "exec ${killgam}; ${gammastep} -P -O 3000; ${monitorControl} -b 25 -c 50, mode \"default\"";
          "4" = "exec ${killgam}; ${gammastep} -P -O 4000; ${monitorControl} -b 35 -c 50, mode \"default\"";
          "5" = "exec ${killgam}; ${gammastep} -P -O 5000; ${monitorControl} -b 45 -c 50, mode \"default\"";
          "6" = "exec ${killgam}; ${gammastep} -x; ${monitorControl} -b 70 -c 70, mode \"default\"";

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
