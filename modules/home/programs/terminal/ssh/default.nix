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
      settings = mkMerge [
        (lib.mkIf config.${namespace}.security.sops.enable {
          "github.com" = {
            HostName = "github.com";
            IdentityFile = config.sops.secrets."ssh/github/private".path;
            IdentitiesOnly = true;
            AddKeysToAgent = "yes";
          };
          "aigpu" = {
            User = "admin";
            HostName = "100.65.28.102";
            IdentityFile = config.sops.secrets."ssh/personal/private".path;
            IdentitiesOnly = true;
            AddKeysToAgent = "yes";
            PreferredAuthentications = "publickey";
          };
        })
        (lib.mkIf (config.${namespace}.security.sops.enable && pkgs.stdenv.isDarwin) {
          "workstation" = {
            HostName = "workstation.tail469983.ts.net";
            User = "nikola";
            IdentityFile = config.sops.secrets."ssh/laptop/private".path;
            IdentitiesOnly = true;
            AddKeysToAgent = "yes";
            SetEnv.TERM = "xterm-256color";
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
