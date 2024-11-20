{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkDefault
    mkMerge
    ;
  inherit (lib.${namespace}) mkOpt enabled;

  cfg = config.${namespace}.user;

  home-directory =
    if cfg.name == null then
      null
    else if pkgs.stdenv.isDarwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{
  options.${namespace}.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    email = mkOpt types.str "nikolamilovic2001@gmail.com" "The email of the user.";
    fullName = mkOpt types.str "Nikola Milovic" "The full name of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    icon =
      mkOpt (types.nullOr types.package) pkgs.${namespace}.user-icon
        "The profile picture to use for the user.";
    name = mkOpt (types.nullOr types.str) config.snowfallorg.user.name "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "${namespace}.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "${namespace}.user.home must be set";
        }
      ];

      xdg = {
        enable = true;
        userDirs =
          let
            appendToHomeDir = path: "${cfg.home}/${path}";
          in
          {
            enable = true;
            desktop = appendToHomeDir "desktop";
            documents = appendToHomeDir "documents";
            download = appendToHomeDir "downloads";
            music = appendToHomeDir "music";
            pictures = appendToHomeDir "pictures";
            publicShare = appendToHomeDir "public";
            templates = appendToHomeDir "templates";
            videos = appendToHomeDir "videos";
          };
      };

      home = {
        file =
          {
            "documents/.keep".text = "";
            "downloads/.keep".text = "";
            "files/.keep".text = "";
            "music/.keep".text = "";
            "pictures/.keep".text = "";
            "videos/.keep".text = "";
          }
          // lib.optionalAttrs (cfg.icon != null) {
            ".face".source = cfg.icon;
            ".face.icon".source = cfg.icon;
            "pictures/${cfg.icon.fileName or (builtins.baseNameOf cfg.icon)}".source = cfg.icon;
          };

        homeDirectory = mkDefault cfg.home;

        shellAliases = { };

        username = mkDefault cfg.name;
      };
    }
  ]);
}
