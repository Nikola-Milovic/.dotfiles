{
  options,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.wezterm;
in
{
  options.config.${namespace}.programs.terminal.wezterm = with types; {
    enable = mkBoolOpt false "Enable wezterm";
  };

  config = mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;
      extraConfig = ''
                local wezterm = require("wezterm")

                local config = {}

                if wezterm.config_builder then
                	config = wezterm.config_builder()
                end

                config.color_scheme = "Tokyo Night Moon"
                config.hide_tab_bar_if_only_one_tab = true

        				-- Maybe needed because of nvidiaì
                config.front_end = "WebGpu"
                config.enable_wayland = false

                -- Disable ligatures
                config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

                return config
      '';
    };

  };
}
