-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Override lazynvim defaults
map("n", "<Left>", "<cmd>wincmd h<cr>", { desc = "Go to left window", remap = true })
map("n", "<Down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window", remap = true })
map("n", "<Up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window", remap = true })
map("n", "<Right>", "<cmd>wincmd l<cr>", { desc = "Go to right window", remap = true })

map("n", "<leader>Ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>Wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>W-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>W|", "<C-W>v", { desc = "Split window right", remap = true })

-- Add my preferences
map("i", "jk", "<esc>", { desc = "Exit insert mode", remap = true })

-- Center search results
map("n", "n", "nzz", { desc = "which_key_ignore" })
map("n", "N", "Nzz", { desc = "which_key_ignore" })

-- next greatest remap ever : asbjornHaland
map("v", "<leader>y", '"+y', { desc = "which_key_ignore" })
map("n", "<leader>y", '"+y', { desc = "which_key_ignore" })
map("v", "p", '"_dP', { desc = "which_key_ignore" })
map("n", "Q", "<nop>", { desc = "which_key_ignore" })
map("n", "Y", "yg$", { desc = "which_key_ignore" })
map("n", "n", "nzzzv", { desc = "which_key_ignore" })
map("n", "N", "Nzzzv", { desc = "which_key_ignore" })
map("n", "J", "mzJ`z", { desc = "which_key_ignore" })
map("n", "<C-d>", "<C-d>zz", { desc = "which_key_ignore" })
map("n", "<C-u>", "<C-u>zz", { desc = "which_key_ignore" })
map("n", "<C-u>", "<C-u>zz", { desc = "which_key_ignore" })

map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "which_key_ignore" })

-- Oil
local oil = require("oil")
map("n", "<leader>E", function()
  oil.open(vim.loop.cwd())
end, { desc = "Open root directory" })
-- map("n", "<leader>", oil.open(vim.loop.cwd()), { desc = "Open root directory" })
map("n", "<leader>e", function()
  oil.open(oil.get_current_dir())
end, { desc = "Open cwd" })
