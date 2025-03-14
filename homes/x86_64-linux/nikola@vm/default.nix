{
  inputs,
  outputs,
  pkgs,
  config,
  system,
  namespace,
  lib,
  ...
}:
with lib.${namespace};
{
  fonts.fontconfig.enable = true;

  # Reload services nicely on config changes
  systemd.user.startServices = "sd-switch";

  custom = {
    theme = {
      catppuccin = enabled;
      vanilla-dmz-cursor = enabled;
    };

    programs = {

      graphical = {
        browsers = {
          brave = enabled;
        };
        obsidian = enabled;
      };

      terminal = {
        ssh = enabled;
        neovim = enabled;
        git = enabled;
        starship = enabled;
        devenv = enabled;
        bash = enabled;
        common = enabled;
        home-manager = enabled;
      };
    };

    security = {
      keyring = enabled;
      sops = {
        enable = true;
        defaultSopsFile = lib.snowfall.fs.get-file "secrets/users/${config.${namespace}.user.name}/secrets.yaml";
      };
    };

    services = {
      syncthing = enabled;
    };

    desktop = {
      wms.sway = {
        enable = true;
        modifier = "Mod4";
        wallpaper = pkgs.custom.wallpapers.galaxy-warm;
      };

      bars.waybar = {
        enable = true;
        debug = true;
        fullSizeOutputs = [ "Virtual-1" ];
        condensedOutputs = [ ];
      };
    };
  };
}
