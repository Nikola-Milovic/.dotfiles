-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Tokyo Night Moon"
--[[ config.set_environment_variables = { ]]
--[[ 	TERMINFO_DIRS = "~/.config/wezterm/.terminfo/w/wezterm", ]]
--[[ } ]]
--[[ config.term = "wezterm" ]]
config.hide_tab_bar_if_only_one_tab = true

return config
