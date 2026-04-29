{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.apps.raycast;
in
{
  options.${namespace}.apps.raycast = {
    enable = mkBoolOpt false "Whether to install Raycast on macOS.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [ "raycast" ];
    };
  };
}
