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
  cfg = config.${namespace}.programming;
in
{
  options.${namespace}.programming = with types; {
    enable = mkBoolOpt osConfig.${namespace}.programming.enable "R U PROGRAMMING?";
  };

  config = mkIf cfg.enable {
    home.persistence."/persist/home/${config.${namespace}.user.name}" = {
      directories = [
        ".config/hcloud"
        ".claude"
      ];
      files = [
        ".claude.json"
      ];
    };
  };
}
