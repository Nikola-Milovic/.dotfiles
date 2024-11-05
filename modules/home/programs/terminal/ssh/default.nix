{
  options,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    optionalString
    mkIf
    types
    ;
  cfg = config.${namespace}.programs.terminal.ssh;
in
{
  options.${namespace}.programs.terminal.ssh = with types; {
    enable = mkEnableOption "SSH Client";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      extraConfig = optionalString config.${namespace}.security.sops.enable ''
        Host github.com
          AddKeysToAgent yes
          Hostname github.com
          IdentitiesOnly yes
          IdentityFile ${config.sops.secrets."github/ssh_pk".path}
      '';
    };
  };
}
