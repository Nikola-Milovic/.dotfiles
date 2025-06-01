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

    boot.initrd.kernelModules = [ "amdgpu" ];

    systemd.packages = with pkgs; [ lact ];
    systemd.services.lactd.wantedBy = [ "multi-user.target" ];

    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];

    environment.systemPackages = with pkgs; [
      clinfo
      lact
    ];
  };
}
