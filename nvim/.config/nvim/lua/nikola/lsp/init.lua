local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "nikola.lsp.lsp-installer"
require("nikola.lsp.handlers").setup()
require "nikola.lsp.null-ls"
