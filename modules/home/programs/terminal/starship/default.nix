{
  options,
  config,
  pkgs,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) types mkEnableOption mkIf;
  cfg = config.${namespace}.programs.terminal.starship;
in
{
  options.${namespace}.programs.terminal.starship = with types; {
    enable = mkEnableOption "starship";
  };

  # https://github.com/starship/starship/pull/4439
  config = mkIf cfg.enable {
    # Prompt issues
    home.packages = [ pkgs.bashInteractive ];

    programs.starship = {
      enable = true;
      settings = {
        character = {
          success_symbol = "[➜](bold purple)";
          error_symbol = "[➜](bold red)";
        };

        kubernetes = {
          disabled = false;
        };

        git_branch.format = "on [$symbol$branch(:$remote_branch)]($style) ";

        nix_shell = {
          symbol = " ";
        };

        docker_context = {
          only_with_files = true;
          disabled = false;
          detect_files = [
            ".dockercontext"
          ];
        };

        git_status.disabled = true;
        buf.disabled = true;
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

  };
}
