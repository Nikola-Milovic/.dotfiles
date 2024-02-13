local Util = require("lazyvim.util")

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      require("harpoon"):setup()
    end,
    keys = {
      {
        "<leader>a",
        function()
          local harpoon = require("harpoon")
          harpoon:list():append()
        end,
        desc = "Add to Harpoon",
      },
      {
        "<C-e>",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Toggle Harpoon Quick Menu",
      },
      {
        "<C-h>",
        function()
          local harpoon = require("harpoon")
          harpoon:list():select(1)
        end,
        desc = "which_key_ignore",
      },
      {
        "<C-t>",
        function()
          local harpoon = require("harpoon")
          harpoon:list():select(2)
        end,
        desc = "which_key_ignore",
      },
      {
        "<C-n>",
        function()
          local harpoon = require("harpoon")
          harpoon:list():select(3)
        end,
        desc = "which_key_ignore",
      },
      {
        "<C-s>",
        function()
          local harpoon = require("harpoon")
          harpoon:list():select(4)
        end,
        desc = "which_key_ignore",
      },
    },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader><space>", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
      { "<leader>ff", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
      { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (root dir)" },
    },
    opts = function(_, opts)
      local actions = require("telescope.actions")
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      })
    end,
  },
}
