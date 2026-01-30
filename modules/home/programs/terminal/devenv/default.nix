{
  options,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) types mkEnableOption mkIf;
  cfg = config.${namespace}.programs.terminal.devenv;
in
{
  options.${namespace}.programs.terminal.devenv = with types; {
    enable = mkEnableOption "devenv";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.devenv ];

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    home.file.".direnvrc".text = ''
      # Example: export_alias zz "ls -la"
      export_alias() {
        local name=$1
        shift
        local alias_dir=$PWD/.direnv/aliases
        local target="$alias_dir/$name"

        mkdir -p "$alias_dir"
        PATH_add "$alias_dir"

        echo "#!/usr/bin/env bash" > "$target"
        echo "set -e" >> "$target"
        # We append "\$@" so the script passes its own arguments to the command
        echo "$@ \"\$@\"" >> "$target"

        chmod +x "$target"
      }
    '';
  };
}
