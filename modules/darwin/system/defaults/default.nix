{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.system.defaults;
in
{
  options.${namespace}.system.defaults = {
    enable = mkBoolOpt false "Whether to manage macOS defaults.";
    dockTileSize = mkOpt types.int 48 "Dock tile size.";
  };

  config = mkIf cfg.enable {
    system.defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = false;
        # AeroSpace recommends this because hidden workspaces affect Mission Control sizing.
        # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
        expose-group-apps = true;
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = cfg.dockTileSize;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      # AeroSpace recommends disabling "Displays have separate Spaces" for stability.
      # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
      spaces.spans-displays = true;
    };
  };
}
