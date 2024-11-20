return {
	{
		"folke/tokyonight.nvim",
		lazy = true,
		opts = {
			style = "moon",
			on_highlights = function(hl)
				local muted_white = "#bec3cc"
				local less_saturated_white = "#8f95a1"

				hl.CursorLineNr = { fg = muted_white, bold = true }
				hl.LineNr = { fg = less_saturated_white, bold = true }
				hl.LineNrAbove = { fg = less_saturated_white }
				hl.LineNrBelow = { fg = less_saturated_white }
			end,
		},
	},
	{
		"stevearc/oil.nvim",
		lazy = false,
		keys = function()
			local keys = {
				{
					"<leader>E",
					function()
						require("oil").open(vim.loop.cwd())
					end,
					desc = "Open root directory",
				},
				{
					"<leader>e",
					function()
						local oil = require("oil")
						oil.open(oil.get_current_dir())
					end,
					desc = "Open cwd",
				},
			}

			return keys
		end,
		opts = {
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["<C-h>"] = false,
				["<C-t>"] = false,
			},
		},
		-- dependencies = { "nvim-tree/nvim-web-devicons" },
		dependencies = { "echasnovski/mini.icons" },
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		enabled = false,
	},
}
