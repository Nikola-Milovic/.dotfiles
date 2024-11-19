return {
  -- {
  --   "stevearc/conform.nvim",
  --   opts = {
  --     formatters_by_ft = {
  --       csharp = { "csharpier" },
  --     },
  --   },
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     "Hoffs/omnisharp-extended-lsp.nvim",
  --   },
  --   opts = {
  --     servers = {
  --       omnisharp = {
  --         cmd = { vim.fn.stdpath("data") .. "/mason/packages/omnisharp/omnisharp" },
  --         handlers = {
  --           ["textDocument/definition"] = require("omnisharp_extended").handler,
  --         },
  --         enable_editorconfig_support = true,
  --         enable_ms_build_load_projects_on_demand = false,
  --         enable_roslyn_analyzers = true,
  --         organize_imports_on_format = true,
  --         enable_import_completion = true,
  --         sdk_include_prereleases = true,
  --         analyze_open_documents_only = true,
  --       },
  --     },
  --   },
  -- },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          handlers = {
            ["textDocument/definition"] = function(...)
              return require("omnisharp_extended").handler(...)
            end,
          },
          keys = {
            {
              "gd",
              function()
                require("omnisharp_extended").telescope_lsp_definitions()
              end,
              desc = "Goto Definition",
            },
          },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
          analyze_open_documents_only = true,
          enable_editorconfig_support = true,
        },
      },
    },
  },
}
