{
  lib,
  namespace,
  ...
}:
with lib.${namespace};
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = "nikola";
    stateVersion = 6;
  };

  custom = {
    apps.terminals = enabled;

    system = {
      defaults = {
        enable = true;
        dockTileSize = 48;
      };
      nix = enabled;
      keyboard = {
        enable = true;
        layout = "dvorak";
        remapCapsLockToControl = true;
      };
    };
  };
}
