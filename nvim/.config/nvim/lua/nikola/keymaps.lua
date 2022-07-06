local M = {}

local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

function bind(op, outer_opts)
    outer_opts = outer_opts or opts
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force",
            outer_opts,
            opts or {}
        )
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

M.nmap = bind("n", {noremap = false})
M.nnoremap = bind("n")
M.vnoremap = bind("v")
M.xnoremap = bind("x")
M.inoremap = bind("i")


--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
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
-- Better window navigation
M.nnoremap("<C-h>", "<C-w>h", opts)
M.nnoremap("<C-j>", "<C-w>j", opts)
M.nnoremap("<C-k>", "<C-w>k", opts)
M.nnoremap("<C-l>", "<C-w>l", opts)

-- Resize with arrows
M.nnoremap("<C-Up>", ":resize -2<CR>", opts)
M.nnoremap("<C-Down>", ":resize +2<CR>", opts)
M.nnoremap("<C-Right>", ":vertical resize -2<CR>", opts)
M.nnoremap("<C-Left>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
M.nnoremap("<S-l>", ":bnext<CR>", opts)
M.nnoremap("<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
M.nnoremap("<A-j>", "<Esc>:m .+1<CR>==gi", opts)
M.nnoremap("<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- I sert --
-- Press jk fast to enter
M.inoremap("jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
M.vnoremap("<", "<gv", opts)
M.nnoremap(">", ">gv", opts)

-- Move text up and down
M.vnoremap("<A-j>", ":m .+1<CR>==", opts)
M.vnoremap("<A-k>", ":m .-2<CR>==", opts)
M.vnoremap("p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
M.xnoremap("J", ":move '>+1<CR>gv-gv", opts)
M.xnoremap("K", ":move '<-2<CR>gv-gv", opts)
M.xnoremap("<A-j>", ":move '>+1<CR>gv-gv", opts)
M.xnoremap("<A-k>", ":move '<-2<CR>gv-gv", opts)

-- line numbers
M.nnoremap( "<leader>n", "<cmd> set nu! <CR>", opts)
M.nnoremap( "<leader>rn", "<cmd> set rnu! <CR>", opts)

-- Terminal --
-- Better terminal navigation
-- M.nnoremap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- M.nnoremap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- M.nnoremap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- M.nnoremap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

M.nnoremap("<F11>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
M.nnoremap("<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
M.vnoremap("//", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], opts)
M.nnoremap(
  "<C-p>",
  "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
  opts
)
M.nnoremap("<C-t>", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", opts)
M.nnoremap("<C-s>", "<cmd>vsplit<cr>", opts)

-- Current buffers directory open
M.nnoremap("<C-d>", "<cmd>lcd %:p:h<cr>", opts)

return M
