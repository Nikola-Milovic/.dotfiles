require("nvim-treesitter.configs").setup({
  ensure_installed = { "astro", "tsx", "typescript", "html" },
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
