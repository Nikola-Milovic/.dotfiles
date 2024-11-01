{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.user;
in
{
  options.${namespace}.user = with types; {
    name = mkOpt str "nikola" "The name to use for the user account.";
    fullName = mkOpt str "Nikola Milovic" "The full name of the user.";
    email = mkOpt str "nikolamilovic2001@gmail.com" "The email of the user.";
    hashedPassword = mkOpt str "password" "The hashed password to use when the user is first created.";
    prompt-init = mkBoolOpt true "Whether or not to show an initial message when opening a new shell.";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  config = (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "${namespace}.user.name must be set";
        }
        {
          assertion = cfg.hashedPassword != null;
          message = "${namespace}.user.hashedPassword must be set";
        }
      ];

		environment.systemPackages = with pkgs; [ ];

    custom.home = {
      file = {
        "Desktop/.keep".text = "";
        "Documents/.keep".text = "";
        "Downloads/.keep".text = "";
        "Music/.keep".text = "";
        "Pictures/.keep".text = "";
        "Videos/.keep".text = "";
        "work/.keep".text = "";
      };
    };

    users.users.${cfg.name} = {
      isNormalUser = true;

      inherit (cfg) name hashedPassword;

      home = "/home/${cfg.name}";
      group = "users";

      shell = pkgs.bash;

      # Arbitrary user ID to use for the user. Since I only
      # have a single user on my machines this won't ever collide.
      # However, if you add multiple users you'll need to change this
      # so each user has their own unique uid (or leave it out for the
      # system to select).
      uid = 1000;

      extraGroups = [
				"wheel"
        "systemd-journal"
        "audio"
        "video"
        "input"
        "power"
        "nix"
			] ++ cfg.extraGroups;
    } // cfg.extraOptions;
  }
]);
}
