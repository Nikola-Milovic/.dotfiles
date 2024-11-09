{
  options,
  config,
  osConfig,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    optionalString
    getExe
    ;
  inherit (lib.${namespace}) enabled mkOpt mkBoolOpt;
  cfg = config.${namespace}.programs.graphical.desktop.wms.sway;
  modifier = "Mod4";
in
{
  options.${namespace}.programs.graphical.desktop.wms.sway = with types; {
    enable = mkBoolOpt osConfig.${namespace}.desktop.wms.sway "Sway";
    extraConfig = mkOpt str "" "Additional configuration for the Sway config file.";
    term = mkOpt package pkgs.foot "The terminal to use.";
    filemanager = mkOpt package pkgs.nemo "The file manager to use.";
    launcherCmd = mkOpt str "" "The launcher command to use.";
    wallpaper = mkOpt (nullOr package) null "The wallpaper to display.";
  };

  imports = lib.snowfall.fs.get-non-default-nix-files ./.;

  config = mkIf cfg.enable {
    # Desktop additions
    custom.programs.graphical.desktop.addons = {
      foot = enabled;
      wofi = enabled;
      waybar = enabled;
      wallpapers = enabled;
      keyring = enabled;
			wlogout = enabled;
      nemo = enabled;
    };

    home = {
      packages = with pkgs; [
        xwaylandvideobridge
        swaylock
        swayidle
        xwayland
        sway-contrib.grimshot
        swaylock-fancy

        grim # screenshot functionality
        slurp # screenshot functionality

        wl-clipboard
        wf-recorder
        libinput
        playerctl
        brightnessctl
        glib # for gsettings
        # gtk3.out # for gtk-launch
        gnome.gnome-control-center
      ];

      sessionVariables = {
        SDL_VIDEODRIVER = "wayland";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        _JAVA_AWT_WM_NONREPARENTING = 1;
        MOZ_ENABLE_WAYLAND = 1;
        XDG_SESSION_TYPE = "wayland";
        NIXOS_OZONE_WL = "1";
        XDG_SESSION_DESKTOP = "sway";
        XDG_CURRENT_DESKTOP = "sway";
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      checkConfig = false;

      systemd = {
        enable = true;
        xdgAutostart = true;

        variables = [ "--all" ];
      };

      config = {
        modifier = modifier;
        # Use Mouse+$mod to drag floating windows to their wanted position
        floating.modifier = modifier;
        terminal = getExe cfg.term;
        menu = cfg.launcherCmd;
        input = {
          "*" = {
            xkb_layout = "real-prog-dvorak";
          };
        };

        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 10.0;
        };

        output = mkIf (cfg.wallpaper != null) {
          "*" = {
            bg = "${cfg.wallpaper.gnomeFilePath or cfg.wallpaper} fill";
          };
        };

        startup = [
          # Launch services waiting for the systemd target sway-session.target
          { command = "systemctl --user import-environment; systemctl --user start sway-session.target"; }
          # Start a user session dbus (required for things like starting
          # applications through wofi).
          { command = "dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus"; }
        ];
      };

      extraConfig = ''

        ${(builtins.readFile ./config)}
        ${cfg.extraConfig}
      '';
    };
  };
}