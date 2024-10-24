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

      # TODO: move to golang setup
      # bashrcExtra = ''
      #   export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      # '';

      shellAliases = {
        cat = "bat";
        ls = "eza";
        find = "fd";
        grep = "rg";
        top = "btm";
        # sed="sd" -- can't do this because sd is not compatible with sed's commands that Unix by default uses
        htop = "btm";
        ps = "procs";
        time = "hyperfine";
        cloc = "tokei";
        cd = "z";

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
