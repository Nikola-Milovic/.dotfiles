# Amalgam of https://github.com/Kidsan/nixos-config/blob/main/home/programs/neovim/default.nix
# and https://github.com/KFearsoff/NixOS-config/tree/main/nixosModules/neovim

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

  treesitterWithGrammars = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };
in
{
  options.${namespace}.programs.terminal.neovim = {
    enable = mkBoolOpt false "Enable Neovim";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      NVIVM_PLUGIN_PATH = "${
        pkgs.vimUtils.packDir
          config.home-manager.users.${config.${namespace}.user.name}.programs.neovim.finalPackage.passthru.packpathDirs
      }/pack/myNeovimPackages/start";
    };

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      package = inputs.neovim-nightly.packages.${system}.default;
      defaultEditor = true;
      withNodeJs = true;

      plugins = with pkgs.vimPlugins; [
        # base distro
        LazyVim

        # Coding
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        nvim-snippets
        friendly-snippets
        ts-comments-nvim
        lazydev-nvim
        luvit-meta

        # Editor
        oil-nvim
        grug-far-nvim
        flash-nvim
        which-key-nvim
        gitsigns-nvim
        trouble-nvim
        todo-comments-nvim

        # Formatting
        conform-nvim

        # Linting
        nvim-lint

        # LSP
        nvim-lspconfig

        # TreeSitter
        treesitterWithGrammars
        nvim-treesitter-textobjects
        nvim-ts-autotag

        # UI
        bufferline-nvim
        lualine-nvim
        indent-blankline-nvim
        noice-nvim
        nui-nvim
        dashboard-nvim

        # Util
        persistence-nvim
        plenary-nvim

        # fzf
        fzf-lua

        # Telescope
        telescope-nvim
        dressing-nvim
        telescope-fzf-native-nvim

        # DAP Core
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
        nvim-nio

        # DAP Neovim Lua Adapter
        # one-small-step-for-vimkind

        # Aerial
        aerial-nvim

        # Illuminate
        vim-illuminate

        # Inc-rename
        inc-rename-nvim

        # Leap
        flit-nvim
        leap-nvim
        vim-repeat

        # Navic
        nvim-navic

        # Overseer
        overseer-nvim

        # Clangd Extra
        clangd_extensions-nvim

        # Helm Extra
        vim-helm

        # JSON/YAML Extra
        SchemaStore-nvim # load known formats for json and yaml

        # Markdown Extra
        markdown-preview-nvim
        render-markdown-nvim

        # Python Extra
        neotest-python
        nvim-dap-python
        # venv-selector-nvim

        # Rust Extra
        # crates-nvim
        # rustaceanvim

        # Terraform Extra
        # telescope-terraform-doc-nvim
        # telescope-terraform-nvim

        # LSP Extra
        neoconf-nvim
        none-ls-nvim

        # Test Extra
        neotest

        # Edgy Extra
        # edgy-nvim

        # Treesitter-context Extra
        nvim-treesitter-context

        # # Project Extra
        # project-nvim
        #
        # # Startuptime
        # vim-startuptime

        nvim-web-devicons
        mini-nvim
        nvim-notify
        nvim-lsp-notify

        # smart typing
        guess-indent-nvim

        # LSP
        nvim-lightbulb # lightbulb for quick actions
        nvim-code-action-menu # code action menu

        lazy-nvim

        # Custom
        harpoon2
      ];

      extraPackages = with pkgs; [
        gcc # needed for nvim-treesitter

        # HTML, CSS, JSON
        vscode-langservers-extracted

        # LazyVim defaults
        stylua
        shfmt

        # Markdown extra
        markdownlint-cli2
        marksman

        # JSON and YAML extras
        nodePackages.yaml-language-server

        # Custom
        editorconfig-checker
        shellcheck
      ];
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink (lib.snowfall.fs.get-file "configs/nvim");
      recursive = true;
    };

    xdg.configFile."nvim/init.lua".text = ''
      -- bootstrap lazy.nvim, LazyVim
      vim.opt.runtimepath:append("${treesitter-parsers}")
      require("config.lazy")
    '';
  };
}
