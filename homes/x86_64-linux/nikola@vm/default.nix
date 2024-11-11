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
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  fonts.fontconfig.enable = true;

  custom = {
    theme.catppuccin = enabled;

    security = {
      sops = {
        enable = true;
        defaultSopsFile = lib.snowfall.fs.get-file "secrets/users/${config.${namespace}.user.name}/secrets.yaml";
      };
    };

    programs.terminal = {
      ssh = enabled;
      neovim = enabled;
      git = enabled;
      starship = enabled;
      bash = enabled;
      common = enabled;
      home-manager = enabled;
    };

    desktop = {
      wms.sway = {
        enable = true;
        wallpaper = pkgs.custom.wallpapers.galaxy-warm;
      };

      bars.waybar = {
        enable = true;
        fullSizeOutputs = [ "Virtual-1" ];
        condensedOutputs = [  ];
      };
    };
  };

  # Reload services nicely on config changes
  systemd.user.startServices = "sd-switch";
}
