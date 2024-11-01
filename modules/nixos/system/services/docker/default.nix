{
  options,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.docker;
in
{
  options.${namespace}.services.docker = with types; {
    enable = mkBoolOpt false "Enable docker service";
  };

  config = mkIf cfg.enable {
    custom.user.extraGroups = [ "docker" ];

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
