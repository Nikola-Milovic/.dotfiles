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
        aseprite = enabled;
        browsers = {
          brave = enabled;
        };
        obs-studio = {
          enable = true;
          driPrime = "pci-0000_03_00_0";
        };
        obsidian = enabled;
        text-editor = enabled;
        rustdesk = enabled;
        wayvnc = enabled;
        vlc = enabled;
        torrent = enabled;
        cursor = enabled;
      };

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

    security = {
      keyring = enabled;
      sops = {
        enable = true;
        defaultSopsFile = lib.snowfall.fs.get-file "secrets/users/${config.${namespace}.user.name}/secrets.yaml";
      };
    };

    services = {
      cliproxyapi = disabled;
      syncthing = enabled;
      whisp-away = {
        enable = true;
        accelerationType = "vulkan"; # AMD GPU
        # useClipboard = false; # Type at cursor position
        useClipboard = true; # Copy to clipboard
        defaultBackend = "whisper-cpp";
        defaultModel = "small.en"; # Good balance of speed/quality
      };
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
