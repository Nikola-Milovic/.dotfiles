local status_ok, keymaps = pcall(require, "nikola.keymaps")
if not status_ok then
	return
end
keymaps.nnoremap("<leader>a", function() require("harpoon.mark").add_file() end)
keymaps.nnoremap("<C-e>", function() require("harpoon.ui").toggle_quick_menu() end)
keymaps.nnoremap("<leader>tc", function() require("harpoon.cmd-ui").toggle_quick_menu() end)

keymaps.nnoremap("<C-h>", function() require("harpoon.ui").nav_file(1) end)
keymaps.nnoremap("<C-t>", function() require("harpoon.ui").nav_file(2) end)
keymaps.nnoremap("<C-n>", function() require("harpoon.ui").nav_file(3) end)
keymaps.nnoremap("<C-s>", function() require("harpoon.ui").nav_file(4) end)
