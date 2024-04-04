vim.filetype.add({ extension = { templ = "templ" } })

return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      require("lspconfig.ui.windows").default_options.border = "rounded"
    end,
    servers = {
      tailwindcss = {
        filetypes = { "templ", "astro", "javascript", "typescript", "react" },
        init_options = { userLanguages = { templ = "html" } },
      },
      html = {
        filetypes = { "html", "templ", "astro" },
      },
      htmx = {
        filetypes = { "html", "templ", "astro" },
      },
    },
  },
}
