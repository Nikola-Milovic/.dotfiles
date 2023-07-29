local M = {}
-- https://github.com/alpha2phi/neovim-for-beginner/blob/main/lua/config/lsp/init.lua
-- local util = require "lspconfig.util"
local nvim_lsp = require("lspconfig")

local servers = {
	pylsp = {
		plugins = {
			pylint = { enabled = true, executable = "pylint" },
			pyflakes = { enabled = false },
			pycodestyle = { enabled = false },
			jedi_completion = { fuzzy = true },
			pyls_isort = { enabled = true },
			pylsp_mypy = { enabled = true },
		},
	},
	gdscript = {
		force_setup = true,
		single_file_support = false,
		root_dir = require("lspconfig.util").root_pattern("project.godot", ".git"),
		filetypes = { "gd", "gdscript", "gdscript3" },
	},
	gopls = {
		settings = {
			gopls = {
				usePlaceholders = false,
				env = { GOFLAGS = "-tags=integration" },
			},
		},
		init_options = {
			buildFlags = { "-tags=integration" },
		},
	},
	html = {},
	jsonls = {
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
					-- Setup your lua path
					path = vim.split(package.path, ";"),
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim", "describe", "it", "before_each", "after_each", "packer_plugins" },
					-- disable = { "lowercase-global", "undefined-global", "unused-local", "unused-vararg", "trailing-space" },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
					-- library = vim.api.nvim_get_runtime_file("", true),
					maxPreload = 2000,
					preloadFileSize = 50000,
				},
				completion = { callSnippet = "Replace" },
				telemetry = { enable = false },
			},
		},
	},
	tsserver = {
		root_dir = nvim_lsp.util.root_pattern("package.json"),
		single_file_support = false,
		disable_formatting = true,
	},
	vimls = {},
	tailwindcss = {},
	denols = {
		root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
	},
	svelte = {},
	-- solang = {},
	yamlls = {
		schemastore = {
			enable = true,
		},
	},
	jdtls = {},
	dockerls = {},
	sqlls = {},
	graphql = {},
	bashls = {},
	-- awk_ls = {},
	-- gradle_ls = {
	--   cmd = {
	--     vim.env.HOME
	--       .. "/.local/share/nvim/vscode-gradle/gradle-language-server/build/install/gradle-language-server/bin/gradle-language-server",
	--   },
	--   root_dir = function(fname)
	--     return util.root_pattern(unpack { "settings.gradle", "settings.gradle.kts" })(fname)
	--       or util.root_pattern(unpack { "build.gradle" })(fname)
	--   end,
	--   filetypes = { "groovy" },
	-- },
	marksman = {},
	-- grammarly = {
	--   filetypes = { "markdown", "text" },
	-- },
}

-- local lsp_signature = require "lsp_signature"
-- lsp_signature.setup {
--   bind = true,
--   handler_opts = {
--     border = "rounded",
--   },
-- }

function M.on_attach(client, bufnr)
	-- Enable completion triggered by <C-X><C-O>
	-- See `:help omnifunc` and `:help ins-completion` for more information.
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Use LSP as the handler for formatexpr.
	-- See `:help formatexpr` for more information.
	vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")

	-- Configure key mappings
	require("nikola.lsp.keymaps").setup(client, bufnr)

	-- Configure formatting
	require("nikola.lsp.null-ls.formatters").setup(client, bufnr)

	-- tagfunc
	if client.server_capabilities.definitionProvider then
		vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
	end

	-- Configure for jdtls
	if client.name == "jdt.ls" then
		require("jdtls").setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()
		vim.lsp.codelens.refresh()
	end

	if client.name == "sqls" then
		require("sqls").on_attach(client, bufnr)
	end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		"documentation",
		"detail",
		"additionalTextEdits",
	},
}
M.capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities) -- for nvim-cmp

local opts = {
	on_attach = M.on_attach,
	capabilities = M.capabilities,
	flags = {
		debounce_text_changes = 150,
	},
}

-- Setup LSP handlers
require("nikola.lsp.handlers").setup()

function M.setup()
	-- null-ls
	require("nikola.lsp.null-ls").setup(opts)

	-- Installer
	require("nikola.lsp.mason").setup(servers, opts)
end

local diagnostics_active = true

function M.toggle_diagnostics()
	diagnostics_active = not diagnostics_active
	if diagnostics_active then
		vim.diagnostic.show()
	else
		vim.diagnostic.hide()
	end
end

function M.remove_unused_imports()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })
	vim.cmd("packadd cfilter")
	vim.cmd("Cfilter /main/")
	vim.cmd("Cfilter /The import/")
	vim.cmd("cdo normal dd")
	vim.cmd("cclose")
	vim.cmd("wa")
end

return M
