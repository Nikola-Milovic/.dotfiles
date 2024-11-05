{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib.${namespace};
let
  inherit (lib) mkBoolOption mkIf types;
  cfg = config.${namespace}.programs.graphical.desktop.addons.keyring;
in
{
  options.${namespace}.programs.graphical.desktop.addons.keyring = with types; {
    enable = mkBoolOpt false "Gnome Keyring";
  };

  config = mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;

      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };

    home.packages = with pkgs; [ gnome.seahorse ];
  };
}
