{
  options,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.starship;
in
{
  options.config.${namespace}.programs.terminal.starship = with types; {
    enable = mkBoolOpt false "Enable Starship";
  };

  config = mkIf cfg.enable {
    programs.starship = {

      enable = true;
      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$python"
          "$character"
        ];
        character = {
          success_symbol = "[➜](bold purple)";
          error_symbol = "[➜](bold red)";
        };

        git_branch.format = "on [$symbol$branch(:$remote_branch)]($style) ";

        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

  };
}
