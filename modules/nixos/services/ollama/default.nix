{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.${namespace}.services.ollama;
  package =
    if cfg.acceleration == false then
      pkgs.ollama-cpu
    else
      {
        rocm = pkgs.ollama-rocm;
        cuda = pkgs.ollama-cuda;
        vulkan = pkgs.ollama-vulkan;
      }
      .${cfg.acceleration};
in
{
  options.${namespace}.services.ollama = {
    enable = mkEnableOption "Ollama LLM service";

    acceleration = mkOption {
      type = types.enum [
        "rocm"
        "cuda"
        "vulkan"
        false
      ];
      default = "rocm";
      description = "Hardware acceleration type for the selected Ollama package";
    };

    rocmOverrideGfx = mkOption {
      type = types.str;
      default = "11.0.0";
      description = "HSA_OVERRIDE_GFX_VERSION for ROCm (e.g., 11.0.0 for RX 7000 series)";
    };

    loadModels = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Models to preload on startup";
    };
  };

  config = mkIf cfg.enable {
    ${namespace}.system.impermanence.directories = [
      "/var/lib/private/ollama"
    ];

    services.ollama = {
      enable = true;
      inherit package;
      inherit (cfg) loadModels rocmOverrideGfx;
    };
  };
}
