{
  options,
  inputs,
  system,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.bash;
in
{
  options.${namespace}.programs.terminal.bash = with types; {
    enable = mkBoolOpt false "Enable Bash";
  };

  config = mkIf cfg.enable {

    programs.bash = {
      enable = true;
      enableCompletion = true;

      initExtra = mkIf pkgs.stdenv.isDarwin ''
        if [ -d /Applications/Ghostty.app/Contents/Resources/terminfo ]; then
          export TERMINFO_DIRS="/Applications/Ghostty.app/Contents/Resources/terminfo:$TERMINFO_DIRS"
        fi
      '';

      shellAliases = {
        c = "clear";
        less = "less -x4RFsX";
      };

      sessionVariables = {
        PAGER = "less";
        LESS = "-R";
        LESSOPEN = "| ${pkgs.sourceHighlight}/bin/src-hilite-lesspipe.sh %s";
      };
    };

    home.packages = with pkgs; [
      sourceHighlight
    ];

    home.file."Library/Application Support/com.mitchellh.ghostty/config.ghostty" =
      mkIf pkgs.stdenv.isDarwin
        {
          force = true;
          text = ''
            command = /run/current-system/sw/bin/bash
          '';
        };
  };
}
