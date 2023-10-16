-- https://dzfrias.dev/blog/neovim-unity-setup
-- https://www.mindevice.net/posts/nvchad-unity
local pid = vim.fn.getpid()
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      omnisharp = {
        -- cmd = { "/home/nikola/omnisharp/run", "--languageserver", "--hostPID", tostring(pid) },
        cmd = { "omnisharp-mono", "--languageserver", "--hostPID", tostring(pid) },
        -- use_mono = true,
      },
    },
  },
}
