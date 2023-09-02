local M = {}

local whichkey = require("which-key")

local keymap = vim.api.nvim_set_keymap
local buf_keymap = vim.api.nvim_buf_set_keymap

local function keymappings(client, bufnr)
	local opts = { noremap = true, silent = true }

	-- Key mappings
	keymap("n", "[e", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>", opts)
	keymap("n", "]e", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>", opts)
	keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	keymap("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
	keymap("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
	-- TODO conflict
	keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

	-- Whichkey
	local keymap_leader = {
		l = {
			name = "LSP",
			R = { "<cmd>Trouble lsp_references<cr>", "Trouble References" },
			a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
			d = { "<cmd>Telescope diagnostics<CR>", "Diagnostics" },
			f = { "<cmd>Lspsaga lsp_finder<CR>", "Finder" },
			i = { "<cmd>LspInfo<CR>", "Lsp Info" },
			n = { "<cmd>Lspsaga rename<CR>", "Rename" },
			r = { "<cmd>Telescope lsp_references<CR>", "Diagnostics" },
			s = { "<cmd>Telescope lsp_document_symbols<CR>", "Diagnostics" },
			t = { "<cmd>TroubleToggle<CR>", "Trouble" },
		},
		r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
	}
	if client.server_capabilities.documentFormattingProvider then
		keymap_leader.l.F = { "<cmd>lua vim.lsp.buf.format({async = true})<CR>", "Format Document" }
	end

	local keymap_g = {
		name = "Goto",
		d = { "<Cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
		D = { "<Cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
		s = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
		i = { "<cmd>Telescope lsp_implementations<CR>", "Goto Implementation" },
		t = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Goto Type Definition" },
		l = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Floating diagnostics" },
	}

	whichkey.register(keymap_leader, { buffer = bufnr, prefix = "<leader>" })
	whichkey.register(keymap_g, { buffer = bufnr, prefix = "g" })
end

local function signature_help(client, bufnr)
	local trigger_chars = client.resolved_capabilities.signature_help_trigger_characters
	for _, char in ipairs(trigger_chars) do
		vim.keymap.set("i", char, function()
			vim.defer_fn(function()
				pcall(vim.lsp.buf.signature_help)
			end, 0)
			return char
		end, {
			buffer = bufnr,
			noremap = true,
			silent = true,
			expr = true,
		})
	end
end

function M.setup(client, bufnr)
	keymappings(client, bufnr)
	-- signature_help(client, bufnr) -- use cmp-nvim-lsp-signature-help
end

return M
