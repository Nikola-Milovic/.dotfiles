{
  lib,
  config,
  osConfig,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;
  cfg = config.${namespace}.impermanence;
in
{
  options.${namespace}.impermanence = with types; {
    enable = mkBoolOpt osConfig.${namespace}.system.impermanence.enable "Is home impermanence enabled";
    files = mkOpt (listOf (either str attrs)) [ ] "Additional home files to persist.";
    directories = mkOpt (listOf (either str attrs)) [ ] "Additional home directories to persist.";
  };

  config = mkIf cfg.enable {
    home.persistence."/persist" = {
      directories = [ ] ++ cfg.directories;
      files = [ ] ++ cfg.files;
    };
  };
}
