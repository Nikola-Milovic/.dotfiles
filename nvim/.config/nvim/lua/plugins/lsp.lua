return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = {
        enabled = false,
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
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      local ensure_installed = {
        -- python
        "ruff-lsp", -- lsp
        "pyright", -- lsp
        "black", -- formatter
        "mypy", -- linter

        -- lua
        "lua-language-server", -- lsp
        "stylua", -- formatter

        -- shell
        "bash-language-server", -- lsp
        "shfmt", -- formatter
        "shellcheck", -- linter

        -- yaml
        "yamllint", -- linter

        -- sql
        "sqlfluff", -- linter

        -- rust
        "rust-analyzer", -- lsp
        -- rustfmt -- formatter (install via rustup)

        -- go
        "gopls", -- lsp
        "golangci-lint-langserver", -- lsp
        "golangci-lint", -- linter (required by golanci-lint-langserver?)
        "gofumpt", -- formatter
        "goimports", -- formatter
        "gomodifytags", -- code actions
        "impl", -- code actions

        -- protobuf
        "buf-language-server", -- lsp (prototype, not feature-complete yet, rely on buf for now)
        "buf", -- formatter, linter
        "protolint", -- linter
      }

      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, ensure_installed)
    end,
  },
  { import = "plugins.langs" },
}
