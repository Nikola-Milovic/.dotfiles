local status_ok, keymaps = pcall(require, "nikola.keymaps")
if not status_ok then
	return
end

local M = {}

function M.setup() 
    require("copilot").setup()
end

return M
