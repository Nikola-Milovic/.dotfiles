return {
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
}
