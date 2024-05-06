-- require("config.lazy")
local vscode = require("vscode-neovim")
if vim.g.vscode then
  vim.notify = vscode.notify
end

vim.g.mapleader = " "

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

vim.notify("Loaded nvim config")

map("n", "<leader><leader>", function()
  vscode.call("workbench.action.quickOpen")
end, { remap = true })
