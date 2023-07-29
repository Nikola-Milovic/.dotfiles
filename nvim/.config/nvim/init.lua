require("nikola.options")
require("nikola.keymaps")
require("nikola.plugins")
require("nikola.autocommands")

if vim.fn.executable("nvr") == 1 then
	vim.env.GIT_EDITOR = "nvr --remote-tab-wait +'set bufhidden=delete'"
end
