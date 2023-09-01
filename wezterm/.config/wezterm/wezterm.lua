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

-- Disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

return config
