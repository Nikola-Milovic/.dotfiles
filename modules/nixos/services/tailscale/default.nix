{
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.tailscale;
in
{
  options.${namespace}.services.tailscale = with types; {
    enable = mkEnableOption "Tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    ${namespace}.system.impermanence.directories = [
      "/var/lib/tailscale"
    ];
  };
}
