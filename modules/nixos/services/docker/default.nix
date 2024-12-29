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
      system.impermanence = {
        directories = [ "/var/lib/docker" ];
        userDirectories = [
          ".local/share/docker"
          ".docker"
        ];
      };
    };

    users.users.${config.${namespace}.user.name}.packages = [ pkgs.docker-compose ];

    # # Since we're rootles we can't bind to port :80
    # networking.firewall = {
    #   # Redirect local outgoing traffic destined for port 80 to port 8000
    #   extraCommands = ''
    #     iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-port 8000
    #   '';
    # };

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      # rootless = {
      #   enable = true;
      #   setSocketVariable = true;
      # };
    };
  };
}
