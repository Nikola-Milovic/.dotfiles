{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkEnableOption
    mkOption
    ;
  cfg = config.${namespace}.services.whisp-away;
in
{
  options.${namespace}.services.whisp-away = with types; {
    enable = mkEnableOption "whisp-away voice dictation";

    accelerationType = mkOption {
      type = enum [
        "vulkan"
        "cuda"
        "openvino"
        "cpu"
      ];
      default = "vulkan";
      description = "Hardware acceleration type for whisper models";
    };

    useClipboard = mkOption {
      type = bool;
      default = false;
      description = "Whether to copy to clipboard (true) or type at cursor (false)";
    };

    defaultModel = mkOption {
      type = str;
      default = "small.en";
      description = "Default whisper model to use";
    };

    autoStartDaemon = mkOption {
      type = bool;
      default = true;
      description = "Whether to auto-start the daemon on login";
    };

    autoStartTray = mkOption {
      type = bool;
      default = true;
      description = "Whether to auto-start the tray on login";
    };

    defaultBackend = mkOption {
      type = enum [
        "whisper-cpp"
        "faster-whisper"
      ];
      default = "faster-whisper";
      description = "Default whisper backend";
    };
  };

  config = mkIf cfg.enable {
    # Persist whisper model cache
    ${namespace}.impermanence.directories = [
      ".cache/whisper-cpp"
      ".cache/faster-whisper"
    ];

    # Enable the upstream whisp-away service
    services.whisp-away = {
      enable = true;

      inherit (cfg)
        accelerationType
        autoStartDaemon
        autoStartTray
        useClipboard
        defaultModel
        defaultBackend
        ;
    };

    # wtype is needed for Wayland typing mode
    home.packages = lib.mkIf (!cfg.useClipboard) [ pkgs.wtype ];
  };
}
