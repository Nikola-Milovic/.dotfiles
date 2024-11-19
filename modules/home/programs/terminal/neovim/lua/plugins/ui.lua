return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      on_highlights = function(hl)
        local muted_white = "#bec3cc"
        local less_saturated_white = "#8f95a1"

        hl.CursorLineNr = { fg = muted_white, bold = true }
        hl.LineNr = { fg = less_saturated_white, bold = true }
        hl.LineNrAbove = { fg = less_saturated_white }
        hl.LineNrBelow = { fg = less_saturated_white }
      end,
    },
  },
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-t>"] = false,
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    -- opts = function(_, opts)
    --   table.insert(opts.sections.lualine_x, 2, require("lazyvim.util").lualine.cmp_source("codeium"))
    -- end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
}
