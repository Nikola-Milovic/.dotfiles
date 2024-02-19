require("nvim-treesitter.configs").setup({
  auto_install = true,
  highlight = {
    enable = true,
  },
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "NoahTheDuke/vim-just",
    },
    build = ":TSUpdate",
  },
  -- {
  --   "NoahTheDuke/vim-just",
  -- },
  -- {
  --   "IndianBoy42/tree-sitter-just",
  -- },
  -- {
  --   "nathom/filetype.nvim",
  --   lazy = false,
  --   opts = {
  --     overrides = {
  --       literal = {
  --         justfile = "just",
  --       },
  --     },
  --   },
  -- },
}
