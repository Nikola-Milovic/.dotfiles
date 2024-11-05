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
  cfg = config.${namespace}.services.ssh;
  sshSocketPath = "${config.users.users.yourusername.xdg.runtimeDir}/ssh-agent.socket";
in
{
  options.${namespace}.services.ssh = with types; {
    enable = mkEnableOption "SSH";
  };

  config = mkIf cfg.enable {
    users.users = {
      ${config.${namespace}.user.name}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXL3hgnOlMFWc00kvOKsAHcuYbIfLDSEBFq/df6rSOZ nikolamilovic2001@gmail.com"
      ];
    };
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = [ "nikola" ]; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      };
    };
  };
}
