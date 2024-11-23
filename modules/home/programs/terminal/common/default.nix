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

    ${namespace}.impermanence = {
      files = [ ".config/lazygit/state.yml" ];
      directories = [
        ".local/share/atuin"
        ".local/share/zoxide"
      ];
    };

    home.shellAliases = {
      # sed="sd" -- can't do this because sd is not compatible with sed's commands that Unix by default uses
      htop = "btm";
      ps = "procs";
      time = "hyperfine";
      cloc = "tokei";
      cd = "z";
      c = "clear";
      cat = "bat";
      ls = "eza";
      find = "fd";
      grep = "rg";
      top = "btm";

      tmux = "zellij";
      zj = "zellij";
    };

    programs = {
      fd = enabled;
      bat = enabled;
      ripgrep = enabled;

      zellij = enabled;
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };

      yazi = {
        enable = true;
        enableBashIntegration = true;
        settings = {
          manager = {
            sort_by = "extension";
            show_hidden = true;
            show_symlink = true;
          };
        };
      };

      atuin = {
        enable = true;
        enableBashIntegration = true;
        flags = [ "--disable-up-arrow" ];
      };
    };

    xdg.configFile."zellij" = {
      source = config.lib.file.mkOutOfStoreSymlink (./zellij);
      recursive = true;
    };
  };
}
