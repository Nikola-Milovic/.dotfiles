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
    ${namespace}.impermanence.files = [
      ".ssh/known_hosts"
      ".ssh/known_hosts.old"
    ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = lib.mkIf config.${namespace}.security.sops.enable {
        "github.com" = {
          hostname = "github.com";
          identityFile = config.sops.secrets."github/ssh_pk".path;
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "aigpu" = {
          user = "admin";
          hostname = "100.65.28.102";
          identityFile = config.sops.secrets."ssh/personal/pk".path;
          identitiesOnly = true;
          addKeysToAgent = "yes";
          extraOptions = {
            PreferredAuthentications = "publickey";
          };
        };
      };
    };
  };
}
