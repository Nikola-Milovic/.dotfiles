local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

-- Browser search
keymap("n", "gx", "<Plug>(openbrowser-smart-search)", default_opts)
keymap("x", "gx", "<Plug>(openbrowser-smart-search)", default_opts)
