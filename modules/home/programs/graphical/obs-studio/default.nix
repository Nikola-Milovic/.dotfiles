{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.${namespace}.programs.graphical.obs-studio;

  gpuEnvironment =
    driPrime:
    pkgs.runCommandLocal "obs-studio-gpu-environment" {
      passthru.obsWrapperArguments = [
        "--set DRI_PRIME ${lib.escapeShellArg driPrime}"
      ];
    } "mkdir -p $out";
in
{
  options.${namespace}.programs.graphical.obs-studio = {
    enable = mkEnableOption "OBS Studio";

    driPrime = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "pci-0000_03_00_0";
      description = "Mesa DRI_PRIME selector for the GPU OBS should use.";
    };
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence.directories = [ ".config/obs-studio" ];

    programs.obs-studio = {
      enable = true;
      plugins = lib.optional (cfg.driPrime != null) (gpuEnvironment cfg.driPrime);
    };

    # Keep `obs` pointed at the managed wrapper inside impure development
    # shells, whose package paths otherwise take precedence over the profile.
    programs.bash.shellAliases.obs = lib.getExe config.programs.obs-studio.finalPackage;
  };
}
