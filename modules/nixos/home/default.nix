{
  options,
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) types mdDoc mkAliasDefinitions;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.home;
in
{
  options.${namespace}.home = with types; {
    file = mkOpt attrs { } (mdDoc "A set of files to be managed by home-manager's `home.file`.");
    configFile = mkOpt attrs { } (
      mdDoc "A set of files to be managed by home-manager's `xdg.configFile`."
    );
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
  };

  config = {
    custom.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions cfg.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.${namespace}.home.configFile;
    };

    snowfallorg.users.${config.${namespace}.user.name}.home.config = cfg.extraOptions;

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };
}
