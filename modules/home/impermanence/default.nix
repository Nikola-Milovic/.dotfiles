{
  options,
  lib,
  config,
  osConfig ? { },
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;
  cfg = config.${namespace}.impermanence;
  osImpermanenceEnabled = lib.attrByPath [
    namespace
    "system"
    "impermanence"
    "enable"
  ] false osConfig;
  hasHomePersistence = lib.hasAttrByPath [ "home" "persistence" ] options;
in
{
  options.${namespace}.impermanence = with types; {
    enable = mkBoolOpt osImpermanenceEnabled "Is home impermanence enabled";
    files = mkOpt (listOf (either str attrs)) [ ] "Additional home files to persist.";
    directories = mkOpt (listOf (either str attrs)) [ ] "Additional home directories to persist.";
  };

  config =
    if hasHomePersistence then
      mkIf cfg.enable {
        home.persistence."/persist" = {
          directories = [ ] ++ cfg.directories;
          files = [ ] ++ cfg.files;
        };
      }
    else
      { };
}
