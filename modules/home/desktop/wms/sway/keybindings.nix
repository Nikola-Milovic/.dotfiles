{
  config,
  osConfig,
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

  # Layout-aware keysym lookup. The keyboard module exports a map from
  # the logical (QWERTY-equivalent) key the user thinks of pressing to
  # the keysym actually produced on the active layout, so bindings
  # below stay layout-agnostic.
  fallbackSymbols = {
    "!" = "exclam";
    "@" = "at";
    "#" = "numbersign";
    "$" = "dollar";
    "%" = "percent";
    "^" = "asciicircum";
    "&" = "ampersand";
    "*" = "asterisk";
    "(" = "parenleft";
    ")" = "parenright";
    backtick = "grave";
    tilde = "asciitilde";
  };
  symbols = lib.attrByPath [ namespace "system" "keyboard" "symbols" ] { } osConfig;
  sym = key: symbols.${key} or fallbackSymbols.${key} or key;

  digits = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "0"
  ];
  shiftedDigits = [
    "!"
    "@"
    "#"
    "$"
    "%"
    "^"
    "&"
    "*"
    "("
    ")"
  ];

  workspaceFocusBindings = lib.listToAttrs (
    lib.imap1 (i: key: {
      name = "${modifier}+Ctrl+${sym key}";
      value = "workspace ${toString i}";
    }) digits
  );

  workspaceMoveBindings = lib.listToAttrs (
    lib.imap1 (i: key: {
      # Shift is consumed by xkb when producing these shifted keysyms.
      # Binding to the symbol itself keeps physical Mod+Shift+number-row
      # workspace moves working on Dvorak layouts.
      name = "${modifier}+${sym key}";
      value = "move container to workspace ${toString i}";
    }) shiftedDigits
  );

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

  volume-mode = "Choose: (1) +5 volume, (2) -5 volume, (3) pavucontrol (4) mute";
  gamma-mode = "Set colour temperature: (a)uto, (r)eset, (1) day, (2) evening, (3) night, (4) very bright day";
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.sway.config = {
      modes = mkOptionDefault {
        "${volume-mode}" = {
          "${sym "1"}" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%, mode \"volume\"";
          "${sym "2"}" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%, mode \"volume\"";
          "${sym "3"}" = "exec ${pavucontrol}, mode \"default\"";
          "${sym "4"}" = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle, mode \"default\"";

          # Exit mode
          Return = "mode \"default\"";
          "Ctrl+c" = "mode \"default\"";
          Escape = "mode \"default\"";
        };
        "${gamma-mode}" = {
          "${sym "1"}" = "${gammastep} -t 5000 -b 0.8;${monitorControl} -b 50 -c 50,mode \"default\"";
          "${sym "2"}" = "${gammastep} -t 3500 -b 0.6;${monitorControl} -b 35 -c 35,mode \"default\"";
          "${sym "3"}" = "${gammastep} -t 7000 -b 1.0;${monitorControl} -b 70 -c 70,mode \"default\"";
          "${sym "4"}" = "${gammastep} -t 1500 -b 0.7;${monitorControl} -b 0 -c 0,mode \"default\"";

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
            "${modifier}+${sym "backtick"}" = "workspace back_and_forth";
          }
          workspaceFocusBindings
          workspaceMoveBindings
          # Voice dictation (whisp-away)
          whispAwayKeybindings
        ];
    };
  };
}
