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
in
{
  options.${namespace}.services.ssh = with types; {
    enable = mkEnableOption "SSH";
  };

  config = mkIf cfg.enable {
    #  users.users = {
    # 	root.openssh.authorizedKeys.keys = [
    # 		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9nKsW0v9SMQo86fxHlX5gnS/ELlWqAS/heyzZ+oPzd iogamastercode@gmail.com"
    # 	];
    # 	${config.user.name}.openssh.authorizedKeys.keys = [
    # 		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9nKsW0v9SMQo86fxHlX5gnS/ELlWqAS/heyzZ+oPzd iogamastercode@gmail.com"
    # 	];
    # };

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "yes"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      };
    };
  };
}
