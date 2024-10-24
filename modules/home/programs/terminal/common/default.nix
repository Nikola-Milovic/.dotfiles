{
  options,
  pkgs,
  inputs,
  system,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.common;
in
{
  options.${namespace}.programs.terminal.common = with types; {
    enable = mkBoolOpt false "Enable common terminal cli's";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      file
      which
      tree
      bottom
      hyperfine
      tokei
      eza
      procs
    ];

    programs = {
      fd = enabled;
      bat = enabled;
      ripgrep = enabled;
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };

      zellij = {
        enable = true;
      };

      atuin = {
        enable = true;
        enableBashIntegration = true;
        flags = [ "--disable-up-arrow" ];
      };
    };

    xdg.configFile = {
      "zellij" = {
        source = config.lib.file.mkOutOfStoreSymlink (lib.snowfall.fs.get-file "configs/zellij");
        recursive = true;
      };
    };

  };
}
