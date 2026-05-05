{
  options,
  config,
  pkgs,
  namespace,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    optionalString
    mkIf
    mkMerge
    types
    ;
  cfg = config.${namespace}.programs.terminal.ssh;
in
{
  options.${namespace}.programs.terminal.ssh = with types; {
    enable = mkEnableOption "SSH Client";
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence.files = lib.mkIf pkgs.stdenv.isLinux [
      ".ssh/known_hosts"
      ".ssh/known_hosts.old"
    ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = mkMerge [
        (lib.mkIf config.${namespace}.security.sops.enable {
          "github.com" = {
            hostname = "github.com";
            identityFile = config.sops.secrets."ssh/github/private".path;
            identitiesOnly = true;
            addKeysToAgent = "yes";
          };
          "aigpu" = {
            user = "admin";
            hostname = "100.65.28.102";
            identityFile = config.sops.secrets."ssh/personal/private".path;
            identitiesOnly = true;
            addKeysToAgent = "yes";
            extraOptions = {
              PreferredAuthentications = "publickey";
            };
          };
        })
        (lib.mkIf (config.${namespace}.security.sops.enable && pkgs.stdenv.isDarwin) {
          "workstation" = {
            hostname = "100.85.47.92";
            user = "nikola";
            identityFile = config.sops.secrets."ssh/laptop/private".path;
            identitiesOnly = true;
            addKeysToAgent = "yes";
            setEnv.TERM = "xterm-256color";
          };
        })
      ];
    };

    programs.bash.initExtra = lib.mkIf pkgs.stdenv.isDarwin ''
      __custom_reset_terminal_input_modes() {
        printf '\033[?9l\033[?1000l\033[?1001l\033[?1002l\033[?1003l\033[?1005l\033[?1006l\033[?1015l\033[?1004l\033[?2004l'
      }

      reset-terminal-input() {
        __custom_reset_terminal_input_modes
      }

      ssh() {
        command ssh "$@"
        local status=$?
        __custom_reset_terminal_input_modes
        return "$status"
      }
    '';
  };
}
