local whichkey = require("which-key")

vim.opt_local.commentstring = "//%s"
vim.opt_local.expandtab = false
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.tabstop = 4
vim.opt.listchars = "eol:$"

local keymap = {
	G = {
		name = "Golang",
		f = {
			name = "AutoFill",
			e = {
				"<cmd> GoIfErr <CR>",
				"Add If Error",
			},
			s = {
				"<cmd> GoFillStruct <CR>",
				"Fill struct",
			},
			p = {
				"<cmd> GoFixPlurals <CR>",
				"foo (b int, a int) -> foo (b, a int)",
			},
			w = {
				"<cmd> GoFillSwitch <CR>",
				"Fill switch",
			},
		},
		g = {
			"<cmd> GoGenerate <CR>",
			"Generate",
		},
		r = {
			"<cmd> GoRun <CR>",
			"Run .",
		},
		b = {
			"<cmd> GoBuild <CR>",
			"Build",
		},
		t = {
			name = "Test",
			c = {
				"<cmd> GoTest -c <CR>",
				"Test current file path",
			},
			n = {
				"<cmd> GoTest -n <CR>",
				"Test nearest",
			},
			f = {
				"<cmd> GoTest -f <CR>",
				"Test current file",
			},
			p = {
				"<cmd> GoTest -p <CR>",
				"Test current package",
			},
		},
		l = {
			"<cmd> GoLint <CR>",
			"Lint",
		},
		v = {
			"<cmd> GoVet <CR>",
			"Vet",
		},
		c = {
			"<cmd> GoCoverage <CR>",
			"Coverage",
		},
		o = {
			"<cmd> GoCoverage -f  <CR>",
			"Load coverage file",
		},
		C = {
			"<cmd> GoTermClose <CR>",
			"Close floating term",
		},
		O = {
			"<cmd>GoPkgOutline <CR>",
			"Package outline",
		},
		d = {
			name = "Debug",
			d = {
				"<cmd>GoDebug <CR>",
				"Start debugger",
			},
			t = {
				"<cmd>GoBreakToggle <CR>",
				"Toggle break point",
			},
			c = {
				"<cmd>BreakCondition <CR>",
				"Conditional break point",
			},
		},
	},
}
local bufnr = vim.api.nvim_get_current_buf()
whichkey.register(keymap, { buffer = bufnr, prefix = "<leader>" })
