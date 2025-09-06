local function has_words_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			signature = { enabled = true, window = { border = "single" } },
			completion = {
				menu = { border = "single" },
				documentation = { window = { border = "single" } },
			},
			keymap = {
				-- We set preset to 'none' to avoid conflicts with our custom mappings.
				preset = "none",

				-- Select next/previous item (and auto-insert the text)
				["<C-j>"] = { "select_prev" },
				["<C-k>"] = { "select_next" },

				-- Scroll documentation
				["<C-b>"] = { "scroll_documentation_up" },
				["<C-f>"] = { "scroll_documentation_down" },

				-- Manually trigger completion
				["<C-Space>"] = { "show" },

				-- Abort/cancel completion
				["<C-e>"] = { "cancel" },

				-- Accept the selected item (like nvim-cmp's `confirm({ select = true })`)
				["<CR>"] = { "select_and_accept" },
				["<S-CR>"] = { "select_and_accept" }, -- blink.cmp's accept is replace by default

				-- Complex Tab mapping
				["<Tab>"] = {
					function(cmp)
						-- If the menu is visible, select the next item
						if cmp.menu_visible() then
							cmp.select_next()
							return true -- Mark as handled
						end
						-- If a snippet is active, jump forward
						if cmp.snippet_active({ direction = 1 }) then
							cmp.snippet_forward()
							return true -- Mark as handled
						end
						-- If there are words before the cursor, trigger completion
						if has_words_before() then
							cmp.show()
							return true -- Mark as handled
						end
						-- If none of the above, return false to trigger the fallback
						return false
					end,
					"fallback", -- Fallback to inserting a Tab character
				},

				-- Complex Shift-Tab mapping
				["<S-Tab>"] = {
					function(cmp)
						-- If the menu is visible, select the previous item
						if cmp.menu_visible() then
							cmp.select_prev()
							return true -- Mark as handled
						end
						-- If a snippet is active, jump backward
						if cmp.snippet_active({ direction = -1 }) then
							cmp.snippet_backward()
							return true -- Mark as handled
						end
						-- Otherwise, trigger fallback
						return false
					end,
					"fallback", -- Fallback to Neovim's default S-Tab behavior
				},
			},
		},
	},
}

-- return {
-- 	{
-- 		"hrsh7th/nvim-cmp",
-- 		---@param opts cmp.ConfigSchema
-- 		opts = function(_, opts)
-- 			local has_words_before = function()
-- 				unpack = unpack or table.unpack
-- 				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
-- 				return col ~= 0
-- 					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- 			end
--
-- 			local luasnip = require("luasnip")
-- 			local cmp = require("cmp")
--
-- 			local cmp_window = require("cmp.config.window")
-- 			opts.window = {
-- 				completion = cmp_window.bordered(),
-- 				documentation = cmp_window.bordered(),
-- 			}
--
-- 			opts.mapping = vim.tbl_extend("force", opts.mapping, {
-- 				["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
-- 				["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
-- 				["<C-b>"] = cmp.mapping.scroll_docs(-4),
-- 				["<C-f>"] = cmp.mapping.scroll_docs(4),
-- 				["<C-Space>"] = cmp.mapping.complete({ reason = cmp.ContextReason.Auto }),
-- 				["<C-e>"] = cmp.mapping.abort(),
-- 				["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
-- 				["<S-CR>"] = cmp.mapping.confirm({
-- 					behavior = cmp.ConfirmBehavior.Replace,
-- 					select = true,
-- 				}),
-- 				["<Tab>"] = cmp.mapping(function(fallback)
-- 					if cmp.visible() then
-- 						-- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
-- 						cmp.select_next_item()
-- 					-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
-- 					-- this way you will only jump inside the snippet region
-- 					elseif luasnip.expand_or_jumpable() then
-- 						luasnip.expand_or_jump()
-- 					elseif has_words_before() then
-- 						cmp.complete()
-- 					else
-- 						fallback()
-- 					end
-- 				end, { "i", "s" }),
-- 				["<S-Tab>"] = cmp.mapping(function(fallback)
-- 					if cmp.visible() then
-- 						cmp.select_prev_item()
-- 					elseif luasnip.jumpable(-1) then
-- 						luasnip.jump(-1)
-- 					else
-- 						fallback()
-- 					end
-- 				end, { "i", "s" }),
-- 			})
-- 		end,
-- 	},
-- }
