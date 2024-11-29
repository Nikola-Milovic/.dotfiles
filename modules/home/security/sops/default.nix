{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types mkEnableOption;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.security.sops;
in
{
  options.${namespace}.security.sops = with types; {
    enable = mkEnableOption "SOPS";
    defaultSopsFile = mkOpt path null "Default sops file.";
    sshKeyPaths = mkOpt (listOf path) [ ] "SSH Key paths to use.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
    ];

    custom.impermanence.directories = [ ".config/sops" ];

    sops = {
      inherit (cfg) defaultSopsFile;
      defaultSopsFormat = "yaml";

      age = {
        generateKey = true;
        keyFile = "${config.${namespace}.user.home}/.config/sops/age/keys.txt";
        sshKeyPaths = [ ] ++ cfg.sshKeyPaths;
      };

      secrets = {
        "github/ssh_pk" = { };
        "ssh/personal/pk" = {
          path = "${config.${namespace}.user.home}/.config/sops/ssh/personal_pk";
        };
      };
    };
  };
}
