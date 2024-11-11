{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.security.polkit;
in
{
  options.${namespace}.security.polkit = {
    enable = mkEnableOption "polkit";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ polkit_gnome ];

    security.polkit = {
      enable = true;
      debug = lib.mkDefault true;

      extraConfig = lib.mkIf config.security.polkit.debug ''
                        /* Log authorization checks. */
                        polkit.addRule(function(action, subject) {
                          polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid + " command " + action.lookup("command"));
                        });

                      /* TODO: temporary solution, need more finegraned permissions */
        							polkit.addRule(function(action, subject) {
        									if (subject.local) return "yes";
        								});
      '';
    };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        after = [ "graphical-session.target" ];
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };
}
