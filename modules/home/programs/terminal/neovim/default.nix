# https://github.com/LazyVim/LazyVim/discussions/1972
# https://github.com/matadaniel/LazyVim-module
{
  pkgs,
  options,
  inputs,
  system,
  config,
  namespace,
  lib,
  ...
}:
# switch to https://github.com/matadaniel/LazyVim-module/tree/main/lazyvim/extras/lang
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;
  cfg = config.${namespace}.programs.terminal.neovim;

  # https://github.com/roobert/tailwindcss-colorizer-cmp.nvim
  tailwind-cmp = pkgs.vimUtils.buildVimPlugin {
    name = "tailwindcss-colorizer-cmp";
    src = pkgs.fetchFromGitHub {
      owner = "roobert";
      repo = "tailwindcss-colorizer-cmp.nvim";
      rev = "3d3cd95e4a4135c250faf83dd5ed61b8e5502b86";
      hash = "sha256-PIkfJzLt001TojAnE/rdRhgVEwSvCvUJm/vNPLSWjpY=";
    };
  };

  # https://github.com/ANGkeith/telescope-terraform-doc.nvim
  telescope-tf-doc = pkgs.vimUtils.buildVimPlugin {
    name = "telescope-terraform-doc.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "ANGkeith";
      repo = "telescope-terraform-doc.nvim";
      rev = "28efe1f3cb2ed4c83fa69000ae8afd2f85d62826";
      hash = "sha256-ZMdsaW9wjmep0CMNCj8k2jSvV8aLMYmiOFm3iD8/pJw=";
    };
  };

  # https://github.com/mfussenegger/nvim-ansible
  nvim-ansible = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-ansible";
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-ansible";
      rev = "44dabdaa8a9193b7f564a8408ed6d7107705030a";
      hash = "sha256-uigPQ6VAXjs52XkYHJMKHxKKwpqnsJmhocsTpMq40ac=";
    };
  };

  blink-compat = pkgs.vimUtils.buildVimPlugin {
    name = "blink.compat";
    src = pkgs.fetchFromGitHub {
      owner = "saghen";
      repo = "blink.compat";
      rev = "2ed6d9a28b07fa6f3bface818470605f8896408c";
      hash = "sha256-GluPgQ8EPH9XXsyLnw//sh1lcDEdcu3VbYQG4ns5JAE=";
    };
  };
in
{
  options.${namespace}.programs.terminal.neovim = {
    enable = mkBoolOpt false "Enable Neovim";
  };

  config = mkIf cfg.enable {

    ${namespace}.impermanence.directories = [
      ".config/github-copilot"
      ".local/state/nvim"
    ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      package = inputs.neovim-nightly.packages.${system}.default;
      withNodeJs = true;
      defaultEditor = true;

      extraPackages = with pkgs; [
        # LazyVim
        lua-language-server
        yaml-language-server

        marksman
        markdownlint-cli2
        stylua
        # jsonls
        # Telescope
        ripgrep
      ];

      plugins = with pkgs.vimPlugins; [ lazy-nvim ];

      extraLuaConfig =
        let
          plugins = with pkgs.vimPlugins; [
            # custom
            {
              name = "harpoon";
              path = harpoon2;
            }
            {
              name = "LuaSnip";
              path = luasnip;
            }
            {
              name = "LuaSnip";
              path = luasnip;
            }
            {
              name = "mini.surround";
              path = mini-surround;
            }
            {
              name = "mini.comment";
              path = mini-comment;
            }
            oil-nvim
            nvim-ts-context-commentstring
            #copilot-lua
            #copilot-cmp
            #blink-cmp-copilot

            supermaven-nvim
            {
              path = blink-compat;
              name = "blink.compat";
            }

            #tailwind
            {
              path = tailwind-cmp;
              name = "tailwindcss-colorizer-cmp";
            }

            #markdown
            markdown-preview-nvim
            render-markdown-nvim

            #Yaml
            SchemaStore-nvim

            # terraform
            {
              path = telescope-tf-doc;
              name = "telescope-terraform-doc.nvim";
            }

            cmp_luasnip

            # C
            cmake-tools-nvim
            clangd_extensions-nvim

            #ansible
            {
              name = "nvim-ansible";
              path = nvim-ansible;
            }

            # LazyVim
            fzf-lua
            blink-cmp
            LazyVim
            bufferline-nvim
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            conform-nvim
            dashboard-nvim
            dressing-nvim
            flash-nvim
            friendly-snippets
            gitsigns-nvim
            grug-far-nvim
            indent-blankline-nvim
            lazydev-nvim
            lualine-nvim
            luvit-meta
            neo-tree-nvim
            noice-nvim
            nui-nvim
            nvim-cmp
            nvim-lint
            nvim-lspconfig
            nvim-notify
            nvim-snippets
            nvim-treesitter
            nvim-treesitter-textobjects
            nvim-ts-autotag
            persistence-nvim
            plenary-nvim
            snacks-nvim
            telescope-fzf-native-nvim
            telescope-nvim
            todo-comments-nvim
            tokyonight-nvim
            trouble-nvim
            ts-comments-nvim
            which-key-nvim
            {
              name = "catppuccin";
              path = catppuccin-nvim;
            }
            {
              name = "mini.ai";
              path = mini-nvim;
            }
            {
              name = "mini.icons";
              path = mini-nvim;
            }
            {
              name = "mini.pairs";
              path = mini-nvim;
            }
          ];
          mkEntryFromDrv =
            drv:
            if lib.isDerivation drv then
              {
                name = "${lib.getName drv}";
                path = drv;
              }
            else
              drv;
          lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
        in
        ''
                              require("lazy").setup({
                              	defaults = {
                              	lazy = true,
                              	},
                              	dev = {
                              	-- reuse files from pkgs.vimPlugins.*
                              	path = "${lazyPath}",
                              	patterns = { "" },
                              	-- fallback to download
                              	fallback = false,
                              	},
                              	spec = {
                              	{ "LazyVim/LazyVim", import = "lazyvim.plugins" },

                              	-- import any extras modules here
                                -- { import = "lazyvim.plugins.extras.ai.copilot" },
          				{ import = "lazyvim.plugins.extras.ai.supermaven" },

                              		{ import = "lazyvim.plugins.extras.coding.mini-comment" },
                              		{ import = "lazyvim.plugins.extras.coding.mini-surround" },

                              		{ import = "lazyvim.plugins.extras.coding.luasnip" },

                              	-- { import = "lazyvim.plugins.extras.formatting.black" },

                              		{ import = "lazyvim.plugins.extras.lang.terraform" },
                              		{ import = "lazyvim.plugins.extras.lang.ansible" },
                              	-- { import = "lazyvim.plugins.extras.lang.astro" },
                              	-- { import = "lazyvim.plugins.extras.lang.svelte" },
                              		{ import = "lazyvim.plugins.extras.lang.python" },
                              		{ import = "lazyvim.plugins.extras.lang.markdown" },
                              	-- { import = "lazyvim.plugins.extras.lang.json" },
                              		{ import = "lazyvim.plugins.extras.lang.go" },
                              		{ import = "lazyvim.plugins.extras.lang.yaml" },
                              		{ import = "lazyvim.plugins.extras.lang.docker" },
                              	-- { import = "lazyvim.plugins.extras.lang.omnisharp" },
                              		{ import = "lazyvim.plugins.extras.lang.tailwind" },
                              		{ import = "lazyvim.plugins.extras.lang.typescript" },

                              		{ import = "lazyvim.plugins.extras.lang.cmake" },
                              		{ import = "lazyvim.plugins.extras.lang.clangd" },

                              	-- The following configs are needed for fixing lazyvim on nix
                              	-- force enable telescope-fzf-native.nvim
                              	{ "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
                              	-- disable mason.nvim, use config.extraPackages
                              	{ "williamboman/mason-lspconfig.nvim", enabled = false },
                              	{ "williamboman/mason.nvim", enabled = false },
                              	-- uncomment to import/override with your plugins
                              	{ import = "plugins" },
                              	-- put this line at the end of spec to clear ensure_installed
                              	{ "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end },
                              	},
                              	performance = {
                              	rtp = {
                              		-- disable some rtp plugins
                              		disabled_plugins = {
                              		"gzip",
                              		-- "matchit",
                              		-- "matchparen",
                              		"netrwPlugin",
                              		"tarPlugin",
                              		"tohtml",
                              		"tutor",
                              		"zipPlugin",
                              		},
                              	},
                              	},
                              })
        '';
    };

    # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
    xdg.configFile."nvim/parser".source =
      let
        parsers = pkgs.symlinkJoin {
          name = "treesitter-parsers";
          paths =
            (pkgs.vimPlugins.nvim-treesitter.withPlugins (
              plugins: with plugins; [
                c
                cpp
                lua
                nix

                go
                gomod
                gowork
                gosum
                templ

                html
                typescript

                python
                rst

                just
                json5
                yaml
                markdown

                graphql

                terraform
                hcl
              ]
            )).dependencies;
        };
      in
      "${parsers}/parser";

    # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
    xdg.configFile."nvim/lua".source = ./lua;
  };
}
