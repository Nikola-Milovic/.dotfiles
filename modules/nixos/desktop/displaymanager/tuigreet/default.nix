{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf getExe mkEnableOption;
  inherit (lib.${namespace});

  cfg = config.${namespace}.desktop.displaymanager.tuigreet;
in
{
  options.${namespace}.desktop.displaymanager.tuigreet = {
    enable = mkEnableOption "tuigreet";
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${getExe pkgs.greetd.tuigreet} --time -r --cmd sway";
          user = "greeter";
        };
      };
    };

    security.pam.services.greetd = {
      enableGnomeKeyring = true;
      gnupg.enable = true;
    };
  };
}
