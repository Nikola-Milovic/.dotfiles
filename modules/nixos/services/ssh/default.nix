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
    users.users = {
      ${config.${namespace}.user.name}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXL3hgnOlMFWc00kvOKsAHcuYbIfLDSEBFq/df6rSOZ nikolamilovic2001@gmail.com"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCW1FA0CO8Zb7Fih2YH1g8eDrqyZB2pWBXRCZM1oClKmQ3WrQ1APW83ly9Q0JLSDvA7gK/Qjo6IcSMXLWvENak0ChHAIXK4W21iUHZM10hFAUGJ+oeR8jdhDLOK+oHpr951xSNzXnKoKfbTBFDIQsuCQgzd3uwAYvogrMDmfYxnxf5+BHgRAwY4BWylkio/aB9js7eIUmrc1x6+VyRVbKdZp45HR4S/V283c2gzM4+I+3+5K0O9MaBEu3jHT5pI67PuAz5KFEgf7CcMeGtoibLt1bqN4T2PZPEQq2w7EUNlE8KCa707bl0/VG/VmEGhZPTidcW7rQ9/joNq6ZAs1qMfA4YMUREgCy3xKxzzCjmUgqa50+sOy9qIvnkeqOhpFs7gTIkfrK7FJjEJVM+izTkoVzSgvfdQB6gZJL50DX3LSBwG7koPaix5n8iI+wsR9DlQD7w183geglAgz9gMSdeAeEz60HN2XShp+QY0rqHOLjPIL9w+tjKOwLQImUSViCX67i62kX+PPDzP02yj/AxFZDUOhnbJUpJHt1p8IV+MJDUE7HdYWo63zyZY71Ao1gdRUrbMGyPjr8a+hGXsYqnPmdQQ05tOyj8Moj7qlKTFcPigI12uXe9YhtmeWBfzpZSotvxFmY8GtWl/c80fLKl8MdekbkDoJ8EzCLbOjtLkow== u0_a486@localhost"
      ];
    };
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      knownHosts = {
        "github/ed25519" = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          hostNames = [ "github.com" ];
        };
        "github/sha2" = {
          publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
          hostNames = [ "github.com" ];
        };
        "github/rsa" = {
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
          hostNames = [ "github.com" ];
        };
      };
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
