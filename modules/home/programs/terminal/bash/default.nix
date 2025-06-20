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

  };
}
