{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.system.homebrew;
in
{
  options.${namespace}.system.homebrew = {
    enable = mkBoolOpt false "Whether to install and manage Homebrew through nix-homebrew.";
    enableRosetta = mkBoolOpt false "Whether to install the Intel Homebrew prefix for Rosetta packages.";
    mutableTaps = mkBoolOpt false "Whether to allow imperative Homebrew tap changes.";
  };

  config = mkIf cfg.enable {
    nix-homebrew = {
      enable = true;
      enableRosetta = cfg.enableRosetta;
      user = config.system.primaryUser;
      autoMigrate = true;
      mutableTaps = cfg.mutableTaps;
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
      };
    };

    homebrew = {
      enable = true;
      taps = builtins.attrNames config.nix-homebrew.taps;
      onActivation = {
        autoUpdate = false;
        upgrade = false;
        cleanup = "none";
      };
    };
  };
}
