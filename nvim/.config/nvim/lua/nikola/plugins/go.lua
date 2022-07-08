-- local path = require 'nvim-lsp-installer.core.path'
-- local install_root_dir = path.concat {vim.fn.stdpath 'data', 'lsp_servers'}
--
vim.cmd([[
  augroup _golang
  autocmd!
  autocmd BufWritePre *.go :silent! lua require('go.format').goimport()
  autocmd BufWritePre (InsertLeave?) <buffer> lua vim.lsp.buf.formatting_sync(nil,500)
augroup end
]])

require("go").setup({
	-- gopls_cmd = {install_root_dir .. '/go/gopls'},
	goimport = "gopls", -- if set to 'gopls' will use golsp format
	fillstruct = "gopls",
	gofmt = "gopls", -- if set to gopls will use golsp format
	max_line_len = 120,
	tag_transform = false,
	test_dir = "",
	comment_placeholder = "   ",
	lsp_cfg = true, -- false: use your own lspconfig
	lsp_gofumpt = true, -- true: set default gofmt in gopls format to gofumpt
	lsp_on_attach = true, -- use on_attach from go.nvim
	dap_debug = true,
})
