{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (lib.${namespace}) capitalize;

  cfg = config.${namespace}.theme.catppuccin;

  warpPkg = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "warp";
    rev = "11295fa7aed669ca26f81ff44084059952a2b528";
    hash = "sha256-ym5hwEBtLlFe+DqMrXR3E4L2wghew2mf9IY/1aynvAI=";
  };

  warpStyle = "${warpPkg.outPath}/themes/catppuccin_macchiato.yml";

  catppuccinAccents = [
    "rosewater"
    "flamingo"
    "pink"
    "mauve"
    "red"
    "maroon"
    "peach"
    "yellow"
    "green"
    "teal"
    "sky"
    "sapphire"
    "blue"
    "lavender"
  ];

  catppuccinFlavors = [
    "latte"
    "frappe"
    "macchiato"
    "mocha"
  ];
in
{
  options.${namespace}.theme.catppuccin = {
    enable = mkEnableOption "Enable catppuccin theme for applications.";

    accent = mkOption {
      type = types.enum catppuccinAccents;
      default = "blue";
      description = ''
        An optional theme accent.
      '';
    };

    flavor = mkOption {
      type = types.enum catppuccinFlavors;
      default = "macchiato";
      description = ''
        An optional theme flavor.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.catppuccin.override {
        inherit (cfg) accent;
        variant = cfg.flavor;
      };
    };
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      theme = {
        gtk = mkIf pkgs.stdenv.isLinux {
          cursor = {
            name = "catppuccin-macchiato-blue-cursors";
            package = pkgs.catppuccin-cursors.macchiatoBlue;
            size = 32;
          };

          icon = {
            name = "Papirus-Dark";
            package = pkgs.catppuccin-papirus-folders.override {
              accent = "blue";
              flavor = "macchiato";
            };
          };

          theme = {
            name = "catppuccin-macchiato-blue-standard";
            package = pkgs.catppuccin-gtk.override {
              accents = [ "blue" ];
              variant = "macchiato";
            };
          };
        };

        qt = mkIf pkgs.stdenv.isLinux {
          theme = {
            name = "Catppuccin-Macchiato-Blue";
            package = pkgs.catppuccin-kvantum.override {
              accent = "blue";
              variant = "macchiato";
            };
          };

          settings = {
            Appearance = {
              color_scheme_path = "${pkgs.catppuccin}/qt5ct/Catppuccin-${capitalize cfg.flavor}.conf";
            };
          };
        };
      };
    };

    catppuccin =
      let
        flavor = "macchiato";
        accent = "blue";
      in
      {
        # NOTE: Need some customization and merging of configuration files so cant just enable all
        enable = false;

        inherit flavor;
        inherit accent;

        bat = {
          enable = true;
          inherit flavor;
        };
        bottom = {
          enable = true;
          inherit flavor;
        };
        btop = {
          enable = true;
          inherit flavor;
        };
        delta = {
          enable = true;
          inherit flavor;
        };
        foot = {
          enable = true;
          inherit flavor;
        };
        fzf = {
          enable = true;
          inherit flavor;
          inherit accent;
        };
        gh-dash = {
          enable = true;
          inherit flavor;
          inherit accent;
        };
        gitui = {
          enable = true;
          inherit flavor;
        };
        glamour = {
          enable = true;
          inherit flavor;
        };
        k9s = {
          enable = true;
          inherit flavor;
        };
        lazygit = {
          enable = true;
          inherit accent;
          inherit flavor;
        };
        nvim = {
          enable = true;
          inherit flavor;
        };
        sway = {
          enable = true;
          inherit flavor;
        };
        waybar = {
          enable = true;
          inherit flavor;
        };
        zellij = {
          enable = true;
          inherit flavor;
        };
        yazi = {
          enable = true;
          inherit accent;
        };
      };

    home = {
      file = mkMerge [
        (mkIf pkgs.stdenv.isDarwin {
          "Library/Application Support/BetterDiscord/themes/catppuccin-macchiato.theme.css".source =
            ./catppuccin-macchiato.theme.css;
        })
      ];

      pointerCursor = mkIf pkgs.stdenv.isLinux {
        inherit (config.${namespace}.theme.gtk.cursor) name package size;
        x11.enable = true;
      };

      sessionVariables = mkIf pkgs.stdenv.isLinux {
        CURSOR_THEME = config.${namespace}.theme.gtk.cursor.name;
      };
    };

    qt = mkIf pkgs.stdenv.isLinux {
      enable = true;

      platformTheme = {
        name = "qtct";
      };

      style = {
        name = "kvantum";
        inherit (config.${namespace}.theme.qt.theme) package;
      };
    };

    # wayland.windowManager.hyprland.catppuccin =
    #   mkIf config.${namespace}.desktop.wms.hyprland.enable
    #     {
    #       enable = true;
    #
    #       inherit (cfg) accent;
    #     };

    wayland.windowManager.sway = {
      config.colors = {
        background = "$base";

        focused = {
          childBorder = "$lavender";
          background = "$base";
          text = "$text";
          indicator = "$rosewater";
          border = "$lavender";
        };

        focusedInactive = {
          childBorder = "$overlay0";
          background = "$base";
          text = "$text";
          indicator = "$rosewater";
          border = "$overlay0";
        };

        unfocused = {
          childBorder = "$overlay0";
          background = "$base";
          text = "$text";
          indicator = "$rosewater";
          border = "$overlay0";
        };

        urgent = {
          childBorder = "$peach";
          background = "$base";
          text = "$peach";
          indicator = "$overlay0";
          border = "$peach";
        };

        placeholder = {
          childBorder = "$overlay0";
          background = "$base";
          text = "$text";
          indicator = "$overlay0";
          border = "$overlay0";
        };

        # bar
        # focusedBackground = "$base";
        # focusedStatusline = "$text";
        # focusedSeparator = "$base";
        # focusedWorkspace = {
        #   border = "$base";
        #   background = "$base";
        #   text = "$green";
        # };
        #
        # activeWorkspace = {
        #   border = "$base";
        #   background = "$base";
        #   text = "$blue";
        # };
        #
        # inactiveWorkspace = {
        #   border = "$base";
        #   background = "$base";
        #   text = "$surface1";
        # };
        #
        # urgentWorkspace = {
        #   border = "$base";
        #   background = "$base";
        #   text = "$peach";
        # };
        #
        # bindingMode = {
        #   border = "$base";
        #   background = "$base";
        #   text = "$surface1";
        # };
      };
    };

    # xdg.configFile =
    #   mkIf (pkgs.stdenv.isLinux && config.${namespace}.programs.graphical.apps.discord.enable)
    #     {
    #       "ArmCord/themes/Catppuccin-Macchiato-BD".source = ./Catppuccin-Macchiato-BD;
    #       "BetterDiscord/themes/catppuccin-macchiato.theme.css".source = ./catppuccin-macchiato.theme.css;
    #     };
  };
}
