{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.apps.terminals;
in
{
  options.${namespace}.apps.terminals = {
    enable = mkBoolOpt false "Whether to install terminal emulator apps on macOS.";
    casks = mkOpt (types.listOf types.str) [
      "ghostty"
      "wezterm"
    ] "Homebrew casks for terminal emulator apps.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = cfg.casks;
    };
  };
}
