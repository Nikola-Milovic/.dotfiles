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
    user = enabled;

    theme = {
      catppuccin = enabled;
      vanilla-dmz-cursor = enabled;
    };

    programming = enabled;

    programs = {
      graphical = {
        browsers = {
          brave = enabled;
        };
        obsidian = enabled;
        sublime = enabled;
        vlc = enabled;
        torrent = enabled;
        cursor = enabled;
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
        wallpaper = pkgs.custom.wallpapers.galaxy-purple;
      };

      bars.waybar = {
        enable = true;
        debug = true;
        fullSizeOutputs = [ "DP-2" ];
        condensedOutputs = [ ];
      };
    };
  };
}
