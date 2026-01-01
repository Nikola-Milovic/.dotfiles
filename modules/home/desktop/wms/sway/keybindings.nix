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
  whispAwayCfg = config.${namespace}.services.whisp-away or { enable = false; };

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
  gammastep = getExe pkgs.custom.gammastep-helper;
  monitorControl = getExe pkgs.custom.monitor-control;

  # Voice dictation keybindings
  whispAwayKeybindings = lib.optionalAttrs whispAwayCfg.enable {
    # Alt+Shift+d to toggle voice dictation
    "${modifier}+Shift+d" = "exec whisp-away toggle";
  };

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
        "${gamma-mode}" = {
          plus = "${gammastep} -t 5000 -b 0.8;${monitorControl} -b 50 -c 50,mode \"default\"";
          bracketleft = "${gammastep} -t 3500 -b 0.6;${monitorControl} -b 35 -c 35,mode \"default\"";
          parenleft = "${gammastep} -t 1500 -b 0.7;${monitorControl} -b 0 -c 0,mode \"default\"";
          braceleft = "${gammastep} -t 7000 -b 1.0;${monitorControl} -b 70 -c 70,mode \"default\"";

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
            "${modifier}+Ctrl+a" = "exec ${obsidian} --disable-gpu";
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
          # Voice dictation (whisp-away)
          whispAwayKeybindings
        ];
    };
  };
}
