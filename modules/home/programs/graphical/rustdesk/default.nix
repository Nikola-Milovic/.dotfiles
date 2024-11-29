{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.graphical.rustdesk;
in
{
  options.${namespace}.programs.graphical.rustdesk = {
    enable = mkEnableOption "rustdesk";
  };

  config = lib.mkIf cfg.enable { home.packages = [ pkgs.rustdesk ]; };
}
