require("nvim-treesitter.configs").setup({
  auto_install = true,
  highlight = {
    enable = true,
  },
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
}
