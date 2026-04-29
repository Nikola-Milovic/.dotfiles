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

  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_COLLATE = "en_US.UTF-8";
  };

  launchd.user.envVariables = {
    LANG = "en_US.UTF-8";
    LC_COLLATE = "en_US.UTF-8";
  };

  custom = {
    apps = {
      terminals = enabled;
      raycast = enabled;
    };

    system = {
      defaults = {
        enable = true;
        dockTileSize = 48;
      };
      nix = enabled;
      keyboard = {
        enable = true;
        layout = "dvorak";
        remapCapsLockToControl = false;
        remapCapsLockToEscape = true;
        remapNonUSTilde = true;
        swapLeftCtrlAndFn = true;
      };
    };
  };
}
