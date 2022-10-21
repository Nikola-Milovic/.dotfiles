local status_ok, keymaps = pcall(require, "nikola.keymaps")
if not status_ok then
	return
end

keymaps.inoremap( "<C-H>",  'copilot#Accept("<CR>")')
keymaps.inoremap( "<C-J>",  'copilot#Previous("<CR>")')
keymaps.inoremap( "<C-K>",  'copilot#Next("<CR>")')

vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

vim.g.copilot_filetypes = {
	["*"] = false,
	["javascript"] = true,
	["typescript"] = true,
	["lua"] = false,
	["rust"] = true,
	["c"] = true,
	["c#"] = true,
	["c++"] = true,
	["go"] = true,
	["python"] = true,
}
