return {
  "hrsh7th/nvim-cmp",
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local cmp_window = require("cmp.config.window")
    opts.window = {
      completion = cmp_window.bordered(),
      documentation = cmp_window.bordered(),
    }
  end,
}
