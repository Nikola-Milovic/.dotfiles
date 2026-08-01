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
  zellijPkgs = inputs.nixpkgs-zellij.legacyPackages.${system};
  zellijWithQuitHint = import ./zellij/package.nix { inherit zellijPkgs; };
in
{
  options.${namespace}.programs.terminal.common = with types; {
    enable = mkBoolOpt false "Enable common terminal cli's";
  };

  config = mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        file
        which
        tree
        bottom
        hyperfine
        tokei
        just
        eza
        procs

        # disk size analyzers, I prefer ncdu
        # dust
        # dua
        ncdu

        sqlite
        rsync

        zip
        unzip

        dig
        inetutils
        lsof

        custom.codex-resets

        inputs.desloppify.packages.${system}.default
      ])
      ++ optionals pkgs.stdenv.isLinux [
        inputs.worktrunk.packages.${system}.worktrunk
      ];

    # TODO: add superfile instead of yazi
    #https://superfile.netlify.app/list/theme-list/

    # https://github.com/nix-community/nix-index-database
    programs.nix-index.enable = false;

    ${namespace}.impermanence = mkIf pkgs.stdenv.isLinux {
      files = [ ".config/pet/snippet.toml" ];
      directories = [
        ".cache/tealdeer"
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
      # find = "fd";
      # grep = "rg";
      top = "btm";

      diskusage = "ncdu /";

      # tmux = "zellij";
      zj = "zellij";
    };

    # worktrunk (wt) shell integration & completions
    programs.bash.initExtra = ''
      if command -v wt >/dev/null 2>&1; then
        eval "$(command wt config shell init bash)"
      fi
    '';

    programs = {
      fd = enabled;
      bat = enabled;
      ripgrep = enabled;
      fzf = enabled;
      jq = enabled;

      tmux = {
        enable = true;
        shell = "${pkgs.bash}/bin/bash";
      };

      # maybe add pet snippets to a gist
      pet = {
        enable = true;
      };

      tealdeer = {
        enable = true;
        settings.update = {
          auto_update = true;
        };
      };

      # TODO: Return to `pkgs.zellij` after https://github.com/openai/codex/issues/33037
      # is fixed. Zellij 0.44.3 can freeze the Codex TUI on focus gain, so pin 0.43.1.
      zellij = {
        enable = true;
        package = zellijWithQuitHint;
      };
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };

      yazi = {
        enable = true;
        enableBashIntegration = true;
        shellWrapperName = "yy";
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
