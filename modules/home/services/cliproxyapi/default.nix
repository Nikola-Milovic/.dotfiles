{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.${namespace}.services.cliproxyapi;
  configPath = config.sops.templates."cliproxyapi-config.yaml".path;
  apiKeyPath = config.sops.secrets."cliproxyapi/api-key".path;

  cliproxyLogin = pkgs.writeShellApplication {
    name = "cliproxy-login";
    text = ''
      if (( $# == 0 )); then
        echo "usage: cliproxy-login <codex|codex-device|claude|kimi>" >&2
        exit 2
      fi

      provider="$1"
      shift

      case "$provider" in
        codex)
          login_flag="--codex-login"
          ;;
        codex-device)
          login_flag="--codex-device-login"
          ;;
        claude)
          login_flag="--claude-login"
          ;;
        kimi)
          login_flag="--kimi-login"
          ;;
        *)
          echo "unsupported provider: $provider" >&2
          exit 2
          ;;
      esac

      exec ${lib.getExe cfg.package} --config ${lib.escapeShellArg configPath} "$login_flag" "$@"
    '';
  };

  claudeRouter = pkgs.writeShellApplication {
    name = "claude-router";
    text = ''
      if [[ ! -r ${lib.escapeShellArg apiKeyPath} ]]; then
        echo "CLIProxyAPI client token is unavailable; activate Home Manager and sops-nix first." >&2
        exit 1
      fi

      claude_bin="$(command -v claude || true)"
      if [[ -z "$claude_bin" ]]; then
        echo "claude is not available on PATH" >&2
        exit 127
      fi

      export ANTHROPIC_BASE_URL="http://127.0.0.1:8317"
      export ANTHROPIC_AUTH_TOKEN
      ANTHROPIC_AUTH_TOKEN="$(< ${lib.escapeShellArg apiKeyPath})"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-5"
      export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="Claude Opus 5 via CLIProxy"

      unset ANTHROPIC_API_KEY
      unset CLAUDE_CODE_SUBAGENT_MODEL

      exec "$claude_bin" --model opus "$@"
    '';
  };
in
{
  options.${namespace}.services.cliproxyapi = {
    enable = mkEnableOption "CLIProxyAPI multi-provider AI model proxy";

    package = mkPackageOption pkgs.${namespace} "cliproxyapi" { };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.${namespace}.security.sops.enable;
        message = "${namespace}.services.cliproxyapi requires ${namespace}.security.sops.enable";
      }
    ];

    home.packages = [
      cfg.package
      cliproxyLogin
      claudeRouter
    ];

    home.file = {
      ".claude/agents/gpt56-worker.md".text = ''
        ---
        name: gpt56-worker
        description: Handles difficult coding, implementation, debugging, and independent verification using GPT-5.6 Sol.
        model: gpt-5.6-sol
        effort: high
        background: true
        ---

        Work independently on the delegated task. Inspect relevant files,
        implement complete changes when requested, run focused verification,
        and return a concise summary with file references and any remaining
        risks.
      '';

      ".claude/agents/kimi-worker.md".text = ''
        ---
        name: kimi-worker
        description: Handles large-context codebase exploration and independent analysis using Kimi K3.
        model: kimi-k3
        effort: high
        background: true
        ---

        Analyze the delegated task independently. Use the available tools,
        verify important conclusions, and return a compact evidence-backed
        summary.
      '';
    };

    ${namespace}.impermanence.directories = [ ".cli-proxy-api" ];

    sops = {
      secrets."cliproxyapi/api-key" = { };

      templates."cliproxyapi-config.yaml" = {
        path = "${config.xdg.configHome}/cliproxyapi/config.yaml";
        mode = "0600";
        content = ''
          host: "127.0.0.1"
          port: 8317

          auth-dir: "${config.home.homeDirectory}/.cli-proxy-api"

          api-keys:
            - "${config.sops.placeholder."cliproxyapi/api-key"}"

          remote-management:
            allow-remote: false
            secret-key: ""
            disable-control-panel: true

          routing:
            strategy: "round-robin"
            session-affinity: true
            session-affinity-ttl: "24h"

          request-retry: 3
          max-retry-interval: 30

          debug: false
          logging-to-file: false
          usage-statistics-enabled: false
        '';
      };
    };

    systemd.user.services.cliproxyapi = {
      Unit = {
        Description = "CLIProxyAPI multi-provider AI model proxy";
        Documentation = "https://help.router-for.me/";
        After = [
          "network-online.target"
          "sops-nix.service"
        ];
        Wants = [ "network-online.target" ];
        Requires = [ "sops-nix.service" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} --config ${configPath}";
        Restart = "on-failure";
        RestartSec = 5;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ "${config.home.homeDirectory}/.cli-proxy-api" ];
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
