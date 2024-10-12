{
	inputs,
	outputs,
  config,
  pkgs,
  username,
  lib,
  ...
}: let
  homeDirectory = "/home/${username}";
  dotfilesPath = "${homeDirectory}/.dotfiles";
in {
  home.username = "${username}";
  home.homeDirectory = "${homeDirectory}";

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays ++ [];

    config = {
      allowUnfree = true;
    };
  };


  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # misc
    cowsay
    file
    which
    tree

    btop

    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zellij = {
    enable = true;
    # enableBashIntegration = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  xdg.configFile = {
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim";
      recursive = true;
    };

    "zellij" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/zellij/.config/zellij";
      recursive = true;
    };
  };

  fonts.fontconfig.enable = true;

  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    extraConfig = ''
      local wezterm = require("wezterm")

      local config = {}

      if wezterm.config_builder then
      	config = wezterm.config_builder()
      end

      config.color_scheme = "Tokyo Night Moon"
      config.hide_tab_bar_if_only_one_tab = true

             -- Maybe needed because of nvidiaì
      config.front_end = "WebGpu"
      config.enable_wayland = false

      -- Disable ligatures
      config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

      return config
    '';
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Nikola-Milovic";
    userEmail = "nikolamilovic2001@gmail.com";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    shellAliases = {
      k = "kubectl";
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Reload services nicely on config changes
  systemd.user.startServices = "sd-switch";
}
