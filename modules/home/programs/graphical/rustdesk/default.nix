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

  config = lib.mkIf cfg.enable {

    custom.impermanence.directories = [ ".config/rustdesk" ];
    home.packages = [ pkgs.rustdesk ];
  };
}
