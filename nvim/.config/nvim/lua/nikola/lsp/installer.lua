local M = {}

function M.setup(servers, options)
  local lspconfig = require "lspconfig"

  -- nvim-lsp-installer must be set up before nvim-lspconfig
  require("nvim-lsp-installer").setup {
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = false,
  }

  -- Set up LSP servers
  for server_name, _ in pairs(servers) do
    local opts = vim.tbl_deep_extend("force", options, servers[server_name] or {})

    if server_name == "tsserver" then
      require("typescript").setup {
        disable_commands = false,
        debug = false,
        server = opts,
      }
    else
      lspconfig[server_name].setup(opts)
    end
  end
end

return M
