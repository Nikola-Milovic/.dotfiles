-- vim.cmd([[
-- try
--   colorscheme tokyonight
-- catch /^Vim\%((\a\+)\)\=:E185/
--   colorscheme default
--   set background=dark
--   hi LineNr guifg=#c2bddb
--   hi CursorLineNr guifg=#ffffff
-- endtry
-- ]])

function ColorScheme()
	vim.cmd("colorscheme tokyonight")

	local hl = function(thing, opts)
		vim.api.nvim_set_hl(0, thing, opts)
	end

	hl("SignColumn", {
		bg = "none",
	})

	hl("ColorColumn", {
		ctermbg = 0,
		bg = "#555555",
	})

	hl("CursorLineNR", {
		bg = "None",
	})

	hl("LineNr", {
		fg = "#5eacd3",
	})

	hl("netrwDir", {
		fg = "#5eacd3",
	})
end

ColorScheme()
