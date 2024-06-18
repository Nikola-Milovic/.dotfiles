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

-- map("n", "<leader><leader>", function()
--   vscode.call("workbench.action.quickOpen")
-- end, { remap = true })
--
-- map("n", "<leader>/", function()
--   vscode.call("workbench.action.findInFiles")
-- end, { remap = true })

-- Harpoon
map("n", "<C-e>", function()
  vim.notify("Harpoon c-e")
  -- vscode.call("vscode-harpoon.editEditors")
end, {})
-- map("n", "<leader>a", function()
--   vscode.call("vscode-harpoon.addEditor")
-- end, { remap = true })
--
-- map("n", "<c-h>", function()
--   vscode.call("vscode-harpoon.gotoEditor1")
-- end, { remap = true })
-- map("n", "<c-t>", function()
--   vscode.call("vscode-harpoon.gotoEditor2")
-- end, { remap = true })
-- map("n", "<c-n>", function()
--   vim.notify("Harpoon c-n")
--   vscode.call("vscode-harpoon.gotoEditor3")
-- end, { remap = true })
-- map("n", "<c-s>", function()
--   vim.notify("Harpoon c-s")
--   vscode.call("vscode-harpoon.gotoEditor4")
-- end, { remap = true })
