{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.foot;
in
{
  options.${namespace}.desktop.addons.foot = with types; {
    enable = mkBoolOpt false "Whether to enable the foot terminal.";
  };

  config = mkIf cfg.enable {
    custom.desktop.addons.term = {
      enable = true;
      pkg = pkgs.foot;
    };

    custom.home.configFile."foot/foot.ini".source = ./foot.ini;
  };
}
