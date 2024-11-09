{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf getExe getExe';
  cfg = config.${namespace}.programs.graphical.desktop.wms.sway;

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
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.sway.config = {
      keybindings =
        with lib;
        mkMerge [
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
