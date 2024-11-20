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
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;
  cfg = config.${namespace}.programs.terminal.neovim;
in
{
  options.${namespace}.programs.terminal.neovim = {
    enable = mkBoolOpt false "Enable Neovim";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      package = inputs.neovim-nightly.packages.${system}.default;
      defaultEditor = true;

      extraPackages = with pkgs; [
        # LazyVim
        lua-language-server
        stylua
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
              name = "mini.surround";
              path = mini-surround;
            }
            {
              name = "mini.comment";
              path = mini-comment;
            }
            oil-nvim
            nvim-ts-context-commentstring

            # LazyVim
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
                              		patterns = { "." },
                              		-- fallback to download
                              		fallback = false,
                              	},
                              	spec = {
                              		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },

                              		-- import any extras modules here
                    --          		{ import = "lazyvim.plugins.extras.ai.copilot" },
                              	--	{ import = "lazyvim.plugins.extras.dap.core" },
                              	--	{ import = "lazyvim.plugins.extras.test.core" },

          													{ import = "lazyvim.plugins.extras.coding.mini-comment" },
          													{ import = "lazyvim.plugins.extras.coding.mini-surround" },

          											    { import = "lazyvim.plugins.extras.coding.luasnip" },

                              	--	{ import = "lazyvim.plugins.extras.formatting.black" },

                              	--	{ import = "lazyvim.plugins.extras.lang.terraform" },
                              	--	{ import = "lazyvim.plugins.extras.lang.astro" },
                              	--	{ import = "lazyvim.plugins.extras.lang.svelte" },
                              	--	{ import = "lazyvim.plugins.extras.lang.python" },
                              	--	{ import = "lazyvim.plugins.extras.lang.markdown" },
                              	--	{ import = "lazyvim.plugins.extras.lang.go" },
                              	--	{ import = "lazyvim.plugins.extras.lang.yaml" },
                              	--	{ import = "lazyvim.plugins.extras.lang.docker" },
                              	--	{ import = "lazyvim.plugins.extras.lang.omnisharp" },
                              	--	{ import = "lazyvim.plugins.extras.lang.tailwind" },
                              	--	{ import = "lazyvim.plugins.extras.lang.typescript" },



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
                lua
                nix
                go
                html
                typescript
                python
              ]
            )).dependencies;
        };
      in
      "${parsers}/parser";

    # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
    xdg.configFile."nvim/lua".source = ./lua;
  };
}
