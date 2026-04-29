{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.system.keyboard;

  dvorakInputSource = {
    InputSourceKind = "Keyboard Layout";
    "KeyboardLayout ID" = 16300;
    "KeyboardLayout Name" = "Dvorak";
  };
in
{
  options.${namespace}.system.keyboard = {
    enable = mkBoolOpt false "Whether to manage macOS keyboard settings.";
    layout = mkOption {
      type = types.enum [
        "qwerty"
        "dvorak"
      ];
      default = "dvorak";
      description = "The macOS keyboard layout to select.";
    };
    remapCapsLockToControl = mkOpt types.bool true "Whether to remap Caps Lock to Control.";
    remapCapsLockToEscape = mkOpt types.bool false "Whether to remap Caps Lock to Escape.";
    remapNonUSTilde = mkOpt types.bool false "Whether to remap the non-US tilde key to grave/tilde.";
    swapLeftCtrlAndFn =
      mkOpt types.bool false
        "Whether to swap the left Control key and Fn (Globe) key.";
  };

  config = mkIf cfg.enable {
    system.keyboard = {
      enableKeyMapping = true;
      inherit (cfg) remapCapsLockToControl remapCapsLockToEscape swapLeftCtrlAndFn;
      nonUS.remapTilde = cfg.remapNonUSTilde;
    };

    system.defaults.NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };

    system.defaults.CustomUserPreferences = mkIf (cfg.layout == "dvorak") {
      "com.apple.HIToolbox" = {
        AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.Dvorak";
        AppleEnabledInputSources = [ dvorakInputSource ];
        AppleSelectedInputSources = [ dvorakInputSource ];
      };
    };
  };
}
