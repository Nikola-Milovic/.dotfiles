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
    --   opts = {
    --     close_if_last_window = true,
    --     enable_diagnostics = false,
    --     enable_git_status = false,
    --     -- use_popups_for_input = false, -- force use vim.input
    --     sort_case_insensitive = true,
    --     window = {
    --       mappings = {
    --         -- Disable neotree's fuzzy finder on `/`, it's annoying when I just want to jump to something I see
    --         ["/"] = "noop",
    --         ["#"] = "noop",
    --         -- Re-enable neotree's fuzzy finder using shifted letters so I can spam shift `/` + shift
    --         -- `f` to activate it, but still do shift `/` + `bla` to search `bla` with vim's search.
    --         ["/F"] = "fuzzy_finder",
    --         ["//"] = "fuzzy_finder", -- alt mapping, nicer?
    --         ["/D"] = "fuzzy_finder_directory", -- only directories
    --       },
    --       fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
    --         ["<C-j>"] = "move_cursor_down",
    --         ["<C-k>"] = "move_cursor_up",
    --       },
    --     },
    --     git_status = {
    --       bind_to_cwd = false,
    --     },
    --     buffers = {
    --       bind_to_cwd = false,
    --     },
    --     filesystem = {
    --       use_libuv_file_watcher = true,
    --       bind_to_cwd = false,
    --       filtered_items = {
    --         visible = true,
    --         hide_dotfiles = false,
    --         hide_gitignored = true,
    --         hide_by_name = {
    --           "node_modules",
    --         },
    --       },
    --     },
    --   },
  },
}
