{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.${namespace}.programs.mkcert;
in
{
  options.${namespace}.programs.mkcert = {
    enable = mkEnableOption "mkcert";
  };

  # Usage:
  # 1. Run `mkcert -install` to create root CA at ~/.local/share/mkcert/
  # 2. Symlink rootCA.pem to this module directory
  # 3. Enable mkcert and rebuild

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mkcert ];

    # Trust the root CA (symlinked from ~/.local/share/mkcert/rootCA.pem)
    # ln -sf ~/.local/share/mkcert/rootCA.pem ~/.dotfiles/modules/nixos/programs/mkcert/rootCA.pem
    security.pki.certificateFiles = [ ./rootCA.pem ];
  };
}