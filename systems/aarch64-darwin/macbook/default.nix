{
  pkgs,
  lib,
  namespace,
  ...
}:
with lib.${namespace};
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  users = {
    knownUsers = [ "nikola" ];
    users.nikola = {
      home = "/Users/nikola";
      shell = pkgs.bashInteractive;
      uid = 501;
    };
  };

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
        remapNonUSTilde = true;
      };
    };
  };
}
