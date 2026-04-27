{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkOption types mkIf;

  cfg = config.${namespace}.system.keyboard;

  availableLayouts = [
    "dvorak"
    "real-prog-dvorak"
    "lemi-dvorak"
  ];

  # Custom layouts that need to be registered with xkb.
  # Built-in xkb variants (e.g. "dvorak") do not appear here.
  extraLayouts = {
    real-prog-dvorak = {
      description = "Real programmers dvorak";
      languages = [ "eng" ];
      symbolsFile = ./keyboards/real-prog-dvorak;
    };
    lemi-dvorak = {
      description = "Lemi dvorak variant";
      languages = [ "eng" ];
      symbolsFile = ./keyboards/lemi-dvorak;
    };
  };

  # Per-layout map from a "logical" key (the QWERTY/US character a user
  # would think of) to the xkb keysym actually produced on that layout.
  # Consumers (e.g. sway keybindings) look up by logical key so bindings
  # can stay layout-agnostic. Lower-case `tilde` / `backtick` entries
  # cover the TLDE position, which lacks a single-char ASCII name here.
  layoutSymbols = rec {
    dvorak = {
      "1" = "1";
      "2" = "2";
      "3" = "3";
      "4" = "4";
      "5" = "5";
      "6" = "6";
      "7" = "7";
      "8" = "8";
      "9" = "9";
      "0" = "0";
      "!" = "exclam";
      "@" = "at";
      "#" = "numbersign";
      "$" = "dollar";
      "%" = "percent";
      "^" = "asciicircum";
      "&" = "ampersand";
      "*" = "asterisk";
      "(" = "parenleft";
      ")" = "parenright";
      backtick = "grave";
      tilde = "asciitilde";
    };

    lemi-dvorak = dvorak // {
      "1" = "plus";
      "2" = "bracketleft";
      "3" = "braceleft";
      "4" = "parenleft";
      "5" = "ampersand";
      "6" = "at";
      "7" = "parenright";
      "8" = "braceright";
      "9" = "bracketright";
      "0" = "asterisk";
      # Shift on the number row produces the digit itself on lemi-dvorak.
      "!" = "1";
      "@" = "2";
      "#" = "3";
      "$" = "4";
      "%" = "5";
      "^" = "6";
      "&" = "7";
      "*" = "8";
      "(" = "9";
      ")" = "0";
      backtick = "dollar";
    };

    # Identical to lemi-dvorak except AE06 produces `equal` instead of `at`.
    real-prog-dvorak = lemi-dvorak // {
      "6" = "equal";
    };
  };

in
{
  options.${namespace}.system.keyboard = with types; {
    layout = mkOption {
      type = enum availableLayouts;
      default = "real-prog-dvorak";
      description = "Selects the custom keyboard layout to be used.";
    };

    symbols = mkOption {
      type = attrsOf str;
      readOnly = true;
      description = ''
        Map from a logical (QWERTY-equivalent) key to the xkb keysym
        produced by that key on the active layout. Use this in
        keybinding definitions so they adapt to the chosen layout.
      '';
    };
  };

  config = mkIf (lib.elem cfg.layout availableLayouts) {
    ${namespace}.system.keyboard.symbols = layoutSymbols.${cfg.layout};

    services.xserver = {
      xkb.extraLayouts = lib.optionalAttrs (extraLayouts ? ${cfg.layout}) {
        ${cfg.layout} = extraLayouts.${cfg.layout};
      };

      xkb.layout = "us";
      xkb.variant = cfg.layout;
    };

    console.useXkbConfig = true;
  };
}
