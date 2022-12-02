local M = {}
local opts = { noremap = true, silent = true }

function bind(op, outer_opts)
	outer_opts = outer_opts or opts
	return function(lhs, rhs, opts)
		opts = vim.tbl_extend("force", outer_opts, opts or {})
		vim.keymap.set(op, lhs, rhs, opts)
	end
end

M.nmap = bind("n", { noremap = false })
M.nnoremap = bind("n")
M.vnoremap = bind("v")
M.xnoremap = bind("x")
M.inoremap = bind("i")

--Remap space as leader key
-- keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- -- Better window navigation
M.nnoremap("<C-Left>", "<C-w>h", opts)
M.nnoremap("<C-Down>", "<C-w>j", opts)
M.nnoremap("<C-Up>", "<C-w>k", opts)
M.nnoremap("<C-Right>", "<C-w>l", opts)

-- Resizing panes
M.nnoremap("<Left>", ":vertical resize +1<CR>", opts)
M.nnoremap("<Right>", ":vertical resize -1<CR>", opts)
M.nnoremap("<Up>", ":resize -1<CR>", opts)
M.nnoremap("<Down>", ":resize +1<CR>", opts)

-- Navigate buffers
M.nnoremap("<S-l>", ":bnext<CR>", opts)
M.nnoremap("<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
M.nnoremap("<A-Down>", "<Esc>:m .+1<CR>==gi", opts)
M.nnoremap("<A-Up>", "<Esc>:m .-2<CR>==gi", opts)

-- I sert --
-- Press jk fast to enter
M.inoremap("jk", "<ESC>", opts)
M.nnoremap("<C-c>", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
M.vnoremap("<", "<gv", opts)
M.vnoremap(">", ">gv", opts)

-- Move text up and down
M.vnoremap("<A-Down>", ":m .+1<CR>==", opts)
M.vnoremap("<A-Up>", ":m .-2<CR>==", opts)

-- Prime

-- next greatest remap ever : asbjornHaland
M.vnoremap("<leader>y", '"+y', opts)
M.nnoremap("<leader>y", '"+y', opts)
M.vnoremap("p", '"_dP', opts)
M.nnoremap("Q", "<nop>", opts)
M.nnoremap("Y", "yg$", opts)
M.nnoremap("n", "nzzzv", opts)
M.nnoremap("N", "Nzzzv", opts)
M.nnoremap("J", "mzJ`z", opts)
M.nnoremap("<C-d>", "<C-d>zz", opts)
M.nnoremap("<C-u>", "<C-u>zz", opts)

-- Visual Block --
-- Move text up and down
M.xnoremap("Down", ":move '>+1<CR>gv-gv", opts)
M.xnoremap("Up", ":move '<-2<CR>gv-gv", opts)
M.xnoremap("<A-Down>", ":move '>+1<CR>gv-gv", opts)
M.xnoremap("<A-Up>", ":move '<-2<CR>gv-gv", opts)

-- line numbers
M.nnoremap("<leader>n", "<cmd> set nu! <CR>", opts)
M.nnoremap("<leader>rn", "<cmd> set rnu! <CR>", opts)

M.vnoremap("//", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], opts)
M.nnoremap("<C-s>", "<cmd>vsplit<cr>", opts)

-- Current buffers directory open
M.nnoremap("<C-d>", "<cmd>lcd %:p:h<cr>", opts)

M.nnoremap("<C-m>", "<cmd>pop<cr>", opts)

M.nnoremap("<leader>eo", "<cmd>NvimTreeToggle<cr>", opts)
M.nnoremap("<leader>e", "<cmd>NvimTreeFocus<cr>", opts)

-- Center search results
M.nnoremap("n", "nzz", opts)
M.nnoremap("N", "Nzz", opts)

M.vnoremap("<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', opts)

return M
