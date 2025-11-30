{
  options,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf types;
  cfg = config.${namespace}.programs.graphical.browsers.brave;
in
{
  options.${namespace}.programs.graphical.browsers.brave = with types; {
    enable = mkEnableOption "brave browser";
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence.directories = [ ".config/BraveSoftware" ];

    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        # "--password-store=gnome-libsecret"
      ];
      extensions = [
        # "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark mode
        # "nngceckbapebfimnlniiiahkandclblb" # bitwarden
        # "niloccemoadcdkdjlinkgdfekeahmflj" # pocket
        # "bjcnpgekponkjpincbcoflgkdomldlnl" # block site
        # "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
        # "edacconmaakjimmfgnblocblbcdcpbko" # session buddy
        # "aapbdbdomjkkjkaonfhkkikfgjllcleb" # translate
        # "pobhoodpcipjmedfenaigbeloiidbflp" # minimal twitter
        # "hlepfoohegkhhmjieoechaddaejaokhf" # refined github
      ];
    };
  };
}
