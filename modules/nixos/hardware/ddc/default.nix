{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.hardware.i2c;
in
{
  options.${namespace}.hardware.i2c = with types; {
    enable = mkEnableOption "i2c";
  };

  # https://github.com/NixOS/nixpkgs/issues/292049
  config = mkIf cfg.enable { hardware.i2c.enable = true; };
}
