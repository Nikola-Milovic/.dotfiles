{
  lib,
  config,
  osConfig,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;
  cfg = config.${namespace}.programming;
in
{
  options.${namespace}.programming = with types; {
    enable = mkBoolOpt osConfig.${namespace}.programming.enable "R U PROGRAMMING?";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devbox
      nodejs_24
    ];
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
    home.persistence."/persist" = {
      directories = [
        ".config/hcloud"
        ".config/claude"
        ".config/stripe"
        ".codex"
        ".claude"
        ".local/share/mkcert"
      ];
      files = [
        ".claude.json"
      ];
    };
  };
}
