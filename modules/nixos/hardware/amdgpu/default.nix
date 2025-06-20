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
    enableRocmSupport = mkEnableOption "support for rocm";
    enableNvtop = mkEnableOption "install nvtop for amd";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.rocmSupport = cfg.enableRocmSupport;

    boot.initrd.kernelModules = [ "amdgpu" ];

    systemd.packages = with pkgs; [ lact ];
    systemd.services.lactd.wantedBy = [ "multi-user.target" ];

    # enables AMDVLK & OpenCL support
    hardware = {
      amdgpu = {
        amdvlk = {
          enable = true;

          support32Bit = {
            enable = true;
          };
          supportExperimental.enable = true;
        };
        initrd.enable = true;
        opencl.enable = true;
      };

      graphics = {
        extraPackages = with pkgs; [
          # mesa
          mesa

          # vulkan
          vulkan-tools
          vulkan-loader
          vulkan-validation-layers
          vulkan-extension-layer

          rocmPackages.clr.icd
          libvdpau-va-gl
        ];
      };
    };

    environment.variables = {
      # VAAPI and VDPAU config for accelerated video.
      # See https://wiki.archlinux.org/index.php/Hardware_video_acceleration
      "VDPAU_DRIVER" = "radeonsi";
      "LIBVA_DRIVER_NAME" = "radeonsi";
    };

    environment.systemPackages =
      with pkgs;
      [
        clinfo
        lact
        amdgpu_top
      ]
      ++ lib.optionals cfg.enableNvtop [
        nvtopPackages.amd
      ];
  };
}
