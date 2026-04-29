{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.desktop.wms.aerospace;

  modifier = cfg.modifier;
  exec = command: "exec-and-forget ${command}";
  # `exec-and-forget` runs through `/bin/bash -c`; use absolute system tools so
  # app launchers do not depend on AeroSpace's launchd PATH.
  # https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
  # https://nikitabobko.github.io/AeroSpace/guide#exec-environment-variables
  openApp = app: ''/usr/bin/open -a "${app}"'';

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

  workspaceFocusBindings = lib.listToAttrs (
    lib.imap1 (i: key: {
      name = "${modifier}-ctrl-${key}";
      value = "workspace ${toString i}";
    }) digits
  );

  workspaceMoveBindings = lib.listToAttrs (
    lib.imap1 (i: key: {
      name = "${modifier}-shift-${key}";
      value = "move-node-to-workspace ${toString i}";
    }) digits
  );

  mainBindings = {
    # Ported from the Sway module where AeroSpace has equivalent commands.
    # Reference config: https://nikitabobko.github.io/AeroSpace/goodies#i3-like-config
    # Application shortcuts
    "${modifier}-ctrl-b" = exec (openApp cfg.braveApp);
    "${modifier}-ctrl-m" = exec (openApp cfg.chromeApp);
    "${modifier}-ctrl-v" = exec (openApp cfg.fileManagerApp);
    "${modifier}-ctrl-a" = exec (openApp cfg.obsidianApp);
    "${modifier}-t" = exec cfg.terminalCommand;
    "${modifier}-d" = exec cfg.launcherCommand;

    # Window management
    "${modifier}-ctrl-q" = "close";
    "${modifier}-shift-space" = "layout floating tiling";
    "${modifier}-f" = "fullscreen";
    "${modifier}-z" = "split horizontal";
    "${modifier}-v" = "split vertical";

    # Screenshots
    "${modifier}-p" = "exec-and-forget /usr/sbin/screencapture -i -c";

    # Focus movement
    "${modifier}-ctrl-h" = "focus left";
    "${modifier}-ctrl-j" = "focus down";
    "${modifier}-ctrl-k" = "focus up";
    "${modifier}-ctrl-l" = "focus right";

    # Layouts
    "${modifier}-s" = "layout v_accordion";
    "${modifier}-w" = "layout h_accordion";
    "${modifier}-e" = "layout tiles horizontal vertical";

    # Modes
    "${modifier}-shift-v" = "mode volume";

    # Configuration reloads
    "${modifier}-shift-c" = "reload-config";

    # Move workspace between monitors
    "${modifier}-ctrl-shift-period" = "move-workspace-to-monitor --wrap-around right";
    "${modifier}-ctrl-shift-comma" = "move-workspace-to-monitor --wrap-around left";

    # Workspace back and forth
    "${modifier}-backtick" = "workspace-back-and-forth";
  };

  volumeBindings = {
    "1" = "volume up";
    "2" = "volume down";
    "3" = [
      (exec ''/usr/bin/open -a "System Settings"'')
      "mode main"
    ];
    "4" = "volume mute-toggle";

    enter = "mode main";
    esc = "mode main";
    "ctrl-c" = "mode main";
  };
in
{
  options.${namespace}.desktop.wms.aerospace = {
    enable = mkBoolOpt false "Whether to enable AeroSpace on macOS.";
    modifier = mkOpt types.str "alt" "AeroSpace modifier key name.";
    keyMappingPreset = mkOpt (types.enum [
      "qwerty"
      "dvorak"
      "colemak"
    ]) "dvorak" "AeroSpace keyboard mapping preset.";
    terminalCommand =
      mkOpt types.str "/usr/bin/open -n /Applications/Ghostty.app"
        "Command used to open a terminal.";
    launcherCommand =
      mkOpt types.str ''/usr/bin/open "raycast://"''
        "Command used to open the launcher.";
    braveApp = mkOpt types.str "Brave Browser" "macOS application name for Brave.";
    chromeApp = mkOpt types.str "Google Chrome" "macOS application name for Chrome.";
    fileManagerApp = mkOpt types.str "Finder" "macOS application name for the file manager.";
    obsidianApp = mkOpt types.str "Obsidian" "macOS application name for Obsidian.";
  };

  config = mkIf cfg.enable {
    programs.aerospace = {
      enable = true;

      # Home Manager writes ~/.config/aerospace/aerospace.toml and owns launchd.
      # https://home-manager-options.extranix.com/?query=programs.aerospace&release=release-25.11
      launchd.enable = true;

      userSettings = {
        # Keep version-gated keys like `config-version` and `persistent-workspaces`
        # out of this generated config. Older AeroSpace releases reject unknown keys.
        # Default config reference: https://nikitabobko.github.io/AeroSpace/guide#default-config

        # Keep `split` usable for the Sway-like Alt+z/Alt+v bindings.
        # Command docs: https://nikitabobko.github.io/AeroSpace/commands#split
        "enable-normalization-flatten-containers" = false;
        "enable-normalization-opposite-orientation-for-nested-containers" = false;
        "on-focused-monitor-changed" = [ "move-mouse monitor-lazy-center" ];

        # AeroSpace interprets binding names as qwerty by default; this keeps
        # bindings natural with the macOS Dvorak input source.
        # https://nikitabobko.github.io/AeroSpace/guide#keyboard-layouts-and-key-mapping
        key-mapping.preset = cfg.keyMappingPreset;

        gaps = {
          inner = {
            horizontal = 8;
            vertical = 8;
          };
          outer = {
            left = 0;
            bottom = 0;
            top = 0;
            right = 0;
          };
        };

        mode = {
          # `mode.*.binding` is source-of-truth in custom configs; defaults are not merged.
          # Guide: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          main.binding = mainBindings // workspaceFocusBindings // workspaceMoveBindings;
          volume.binding = volumeBindings;
        };
      };
    };
  };
}
