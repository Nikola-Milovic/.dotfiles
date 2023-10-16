local Util = require("lazyvim.util")

return {
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
}
