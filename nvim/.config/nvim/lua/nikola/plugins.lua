require("nikola.plugins.telescope")
--[[ require("nikola.plugins.copilot") ]]
require("nikola.plugins.close-buffer")
require("nikola.plugins.treesitter")
require("nikola.plugins.treesitter-context")
require("nikola.plugins.comment")
require("nikola.plugins.bufferline")
require("nikola.plugins.lualine")
require("nikola.plugins.toggleterm")
require("nikola.plugins.impatient")
require("nikola.plugins.indentline")
require("nikola.plugins.alpha")
require("nikola.plugins.whichkey")
require("nikola.plugins.cmp")
require("nikola.plugins.go")
require("nikola.plugins.rust")
require("nikola.plugins.harpoon")
require("nikola.plugins.worktree")

local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	use("wbthomason/packer.nvim") -- Have packer manage itself
	use("nvim-lua/popup.nvim") -- An implementation of the Popup API from vim in Neovim
	use("nvim-lua/plenary.nvim") -- Useful lua functions used ny lots of plugins
	use("numToStr/Comment.nvim") -- Easily comment stuff
	use("akinsho/bufferline.nvim")
	use("nvim-lualine/lualine.nvim")
	use("akinsho/toggleterm.nvim")
	use("lewis6991/impatient.nvim")
	use("lukas-reineke/indent-blankline.nvim")
	use("goolord/alpha-nvim")
	use("folke/which-key.nvim")
	use("ThePrimeagen/harpoon")

	-- Colorschemes
	use("folke/tokyonight.nvim")

	-- cmp plugins
	use("hrsh7th/nvim-cmp") -- The completion plugin
	use("hrsh7th/cmp-buffer") -- buffer completions
	use("hrsh7th/cmp-path") -- path completions
	use("hrsh7th/cmp-cmdline") -- cmdline completions
	use("saadparwaiz1/cmp_luasnip") -- snippet completions
	use("hrsh7th/cmp-nvim-lsp")

	use("kazhala/close-buffers.nvim")

	use({
		"zbirenbaum/copilot.lua",
		event = "VimEnter",
		config = function()
			vim.defer_fn(function()
				require("nikola.plugins.copilot").setup()
			end, 100)
		end,
	})
	use({
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			vim.defer_fn(function()
				require("copilot_cmp").setup()
			end, 200)
		end,
	})

	-- snippets
	use("L3MON4D3/LuaSnip") --snippet engine
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

	-- LSP
	use({
		"neovim/nvim-lspconfig",
		wants = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"lua-dev.nvim",
			"vim-illuminate",
			"null-ls.nvim",
			"schemastore.nvim",
			"typescript.nvim",
		},
		config = function()
			require("nikola.lsp").setup()
		end,
		requires = {
			"folke/neodev.nvim",
			"williamboman/mason.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"williamboman/mason-lspconfig.nvim",
			"folke/lua-dev.nvim",
			"RRethy/vim-illuminate",
			"jose-elias-alvarez/null-ls.nvim",
			{
				"j-hui/fidget.nvim",
				config = function()
					require("fidget").setup()
				end,
			},
			"b0o/schemastore.nvim",
			"jose-elias-alvarez/typescript.nvim",
		},
	})

	-- nvim-tree
	use("kyazdani42/nvim-web-devicons")
	use({
		"kyazdani42/nvim-tree.lua",
		--[[ opt = true, ]]
		wants = "nvim-web-devicons",
		--[[ cmd = { "NvimTreeToggle", "NvimTreeClose", "NvimTreeFocus" }, ]]
		-- module = "nvim-tree",
		config = function()
			require("nikola.plugins.nvim-tree").setup()
		end,
	})

	-- trouble.nvim
	use({
		"folke/trouble.nvim",
		wants = "nvim-web-devicons",
		-- cmd = { "TroubleToggle", "Trouble" },
		config = function()
			require("trouble").setup({
				use_diagnostic_signs = true,
			})
		end,
	})

	-- languages
	use({
		"ray-x/go.nvim",
		run = ":GoInstallBinaries",
	})
	use("ray-x/guihua.lua")
	use("ray-x/sad.nvim")

	-- rust
	use("simrat39/rust-tools.nvim")

	-- -- Debug
	use({
		"mfussenegger/nvim-dap",
		module = { "dap" },
		opt = true,
		-- event = "BufReadPre",
		keys = { [[<leader>d]] },
		wants = { "nvim-dap-virtual-text", "nvim-dap-ui", "which-key.nvim" },
		requires = {
			"theHamsta/nvim-dap-virtual-text",
			"rcarriga/nvim-dap-ui",
			"nvim-telescope/telescope-dap.nvim",
			{ "jbyuki/one-small-step-for-vimkind", module = "osv" },
		},
		config = function()
			require("nikola.dap").setup()
		end,
	})

	-- Telescope
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-telescope/telescope-ui-select.nvim",
		},
	})

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})
	use("nvim-treesitter/nvim-treesitter-context")
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("JoosepAlviste/nvim-ts-context-commentstring")

	-- Git
	use("kdheepak/lazygit.nvim")
	use("ThePrimeagen/git-worktree.nvim")

	use({
		"gpanders/editorconfig.nvim",
	})

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
