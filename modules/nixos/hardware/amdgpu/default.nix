{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) enabled;

  cfg = config.${namespace}.hardware.amdgpu;
in
{
  options.${namespace}.hardware.amdgpu = {
    enable = mkEnableOption "amd gpu";
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu.initrd.enable = true;

    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];

    environment.systemPackages = with pkgs; [
      clinfo
    ];
  };
}
