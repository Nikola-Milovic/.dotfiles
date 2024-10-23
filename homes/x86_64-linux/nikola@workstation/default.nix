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
 let 
  inherit (lib.${namespace}) enabled;
 in
 with lib.${namespace}; 
 {
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
      package = inputs.neovim-nightly.packages.${system}.default;
    };

    programs.chromium = {
      enable = true;
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    };

    programs.bat.enable = true;

    programs.ripgrep.enable = true;

    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
    };

    xdg.configFile = {
      "nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink (lib.snowfall.fs.get-file "configs/nvim");
        recursive = true;
      };

      "zellij" = {
        source = config.lib.file.mkOutOfStoreSymlink (lib.snowfall.fs.get-file "configs/zellij");
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

    programs.starship = {
      enable = true;
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
        cat = "bat";
        grep = "ripgrep";
      };
    };

    programs.lazygit.enable = true;

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
    #programs.home-manager.enable = true;

    # Reload services nicely on config changes
    systemd.user.startServices = "sd-switch";
}
