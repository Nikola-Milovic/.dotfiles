{
  options,
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
        # TODO: move to git
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        lg = "lazygit";

        # TODO: install
        # wcl="warp-cli";

        "??" = "gh copilot";

        c = "clear";

        # TODO: move to zellij
        tmux = "zellij";
        zj = "zellij";

      };
    };

  };
}
