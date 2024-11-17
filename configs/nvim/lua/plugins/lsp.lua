return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = {
        enabled = false,
      }
      opts.servers.nixd = {
        cmd = { "nixd" },
        settings = {
          nixd = {
            nixpkgs = {
              expr = "import <nixpkgs> { }",
            },
            formatting = {
              command = { "nixfmt" },
            },
            options = {
              nixos = {
                expr = '(builtins.getFlake "/home/nikola/.dotfiles").nixosConfigurations.workstation.options',
              },
              home_manager = {
                expr = '(builtins.getFlake "/home/nikola/.dotfiles").homeConfigurations."nikola@workstation".options',
              },
            },
          },
        },
      }
      opts.servers.gopls = vim.tbl_deep_extend("force", opts.servers.gopls or {}, {
        settings = {
          gopls = {
            buildFlags = { "-tags=manual" },
          },
        },
      })
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
    },
  },
  { import = "plugins.langs" },
}
