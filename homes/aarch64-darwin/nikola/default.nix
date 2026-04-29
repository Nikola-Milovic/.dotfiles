{
  lib,
  namespace,
  ...
}:
with lib.${namespace};
{
  custom = {
    user = enabled;

    programming = enabled;

    programs = {
      terminal = {
        ssh = enabled;
        git = enabled;
        starship = enabled;
        devenv = enabled;
        bash = enabled;
        common = enabled;
        vim = enabled;
        home-manager = enabled;
      };
    };

    security.sops = {
      enable = true;
      defaultSopsFile = lib.snowfall.fs.get-file "secrets/users/nikola/secrets.yaml";
    };

    desktop.wms.aerospace = enabled;
  };
}
