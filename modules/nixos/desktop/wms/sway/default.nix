{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf getExe mkEnableOption;
  inherit (lib.${namespace}) enabled;

  cfg = config.${namespace}.desktop.wms.sway;
in
{
  options.${namespace}.desktop.wms.sway = {
    enable = mkEnableOption "Sway";
  };

  config = mkIf cfg.enable {
		custom.desktop.addons.xdg-portal = enabled;

    services.xserver.enable = true;
    services.libinput.enable = true;

    # configuring sway itself (assmung a display manager starts it)
    systemd.user.targets.sway-session = {
      description = "Sway compositor session";
      documentation = [ "man:systemd.special(7)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };

    systemd.user.services.sway = {
      description = "Sway - Wayland window manager";
      documentation = [ "man:sway(5)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
      # We explicitly unset PATH here, as we want it to be set by
      # systemctl --user import-environment in startsway
      environment.PATH = lib.mkForce null;
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
        '';
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
