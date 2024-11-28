{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption types mkIf;
  cfg = config.${namespace}.system.keyboard;
in
{
  options.${namespace}.system.keyboard = with types; {
    real-prog-dvorak = mkEnableOption "real prog dvorak";
  };

  config = mkIf cfg.real-prog-dvorak {
    services.xserver = {
      xkb.extraLayouts.real-prog-dvorak = {
        description = "Real programmers dvorak";
        languages = [ "eng" ];
        symbolsFile = ./keyboards/real-prog-dvorak;
      };

      # enable = true;

      xkb.layout = "us";
      xkb.variant = "dvorak";
    };

    console.useXkbConfig = true;
  };
}
