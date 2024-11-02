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
  home.packages = with pkgs; [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

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
    programs.terminal = {
      neovim = enabled;
      starship = enabled;
      bash = enabled;
      common = enabled;
			home-manager = enabled;
    };
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Nikola-Milovic";
    userEmail = "nikolamilovic2001@gmail.com";
  };

  programs.lazygit.enable = true;

  # Reload services nicely on config changes
  systemd.user.startServices = "sd-switch";
}
