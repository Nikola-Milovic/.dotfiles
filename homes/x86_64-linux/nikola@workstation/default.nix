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
        rustdesk = enabled;
        vlc = enabled;
        torrent = enabled;
        cursor = enabled;
        locallm = {
          enable = true;
          defaultModel = "llama3.2:3b";
          showGpuStats = true;
        };
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
