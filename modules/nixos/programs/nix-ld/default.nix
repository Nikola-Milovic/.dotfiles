{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.programs.nix-ld;
in
{
  options.${namespace}.programs.nix-ld = {
    enable = mkEnableOption "nix-ld";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages

      # Playwright/Chromium runtime libs: nix-ld resolves these so Playwright's
      # own downloaded Chromium can launch. Verified vs @playwright/test 1.60.0.
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libxkbcommon
      libxshmfence
      nspr
      nss
      pango
      stdenv.cc.cc.lib
      zlib
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
    ];
  };
}
