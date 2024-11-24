{
  options,
  pkgs,
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
    enable = mkEnableOption "Docker";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      user.extraGroups = [ "docker" ];
      system.impermanence.directories = [ "/var/lib/docker" ];
    };

    users.users.${config.${namespace}.user.name}.packages = [ pkgs.docker-compose ];

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
