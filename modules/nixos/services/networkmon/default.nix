{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  inherit (lib.${namespace}) mkOpt;
  cfg = config.${namespace}.services.networkmon;
in
{
  options.${namespace}.services.networkmon = {
    enable = mkEnableOption "Network connectivity monitor";

    interval = mkOption {
      type = types.int;
      default = 30;
      description = "Check interval in seconds";
    };

    interface = mkOption {
      type = types.str;
      default = "enp119s0";
      description = "Primary network interface to monitor";
    };

    logDir = mkOption {
      type = types.str;
      default = "/var/log/networkmon";
      description = "Directory for JSONL log files";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.networkmon = {
      description = "Network connectivity monitor";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.custom.networkmon}";
        Restart = "on-failure";
        RestartSec = 10;
        LogsDirectory = "networkmon";
        LogsDirectoryMode = "0755";
      };

      environment = {
        NETWORKMON_INTERVAL = toString cfg.interval;
        NETWORKMON_LOG_DIR = cfg.logDir;
        NETWORKMON_IFACE = cfg.interface;
      };
    };

    # Make the analyze CLI available system-wide
    environment.systemPackages = [ pkgs.custom.networkmon-analyze ];

    # Set the log dir for the analyze tool so it finds the right path
    environment.sessionVariables.NETWORKMON_LOG_DIR = cfg.logDir;
  };
}
