{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption types mkIf;
  cfg = config.${namespace}.desktop.addons.xdg-portal;
in
{
  options.${namespace}.desktop.addons.xdg-portal = with types; {
    enable = mkEnableOption "xdg portal";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            (prev.fetchpatch {
              # TODO: Remove this override after nixpkgs packages an
              # xdg-desktop-portal-wlr release containing c613a8bc7cfb
              # (and preferably the follow-up to 0.8.3, which upstream warns
              # can occasionally stall screen recording).
              #
              # Why this is here:
              # - nixpkgs b3fe958 packages xdg-desktop-portal-wlr 0.8.2.
              # - With PipeWire 1.6.6, both the portal and OBS video nodes
              #   reached "running", but had QUANT=0 and RATE=0 because
              #   neither node drove the graph.
              # - Consequently, the portal received no process callback,
              #   never requested a frame from Sway, and OBS recorded a
              #   one-color black frame. GPU selection, DMA-BUF modifiers,
              #   SHM fallback, and the legacy screencopy protocol were all
              #   tested and ruled out.
              # - This upstream patch marks the portal stream as a PipeWire
              #   driver, requests the first frame when streaming starts,
              #   and triggers processing after each ext-image-copy frame.
              #
              # Before removing it, verify the packaged source contains this
              # commit, rebuild, and make a short OBS recording. A working
              # frame should contain real image data rather than solid black.
              url = "https://github.com/emersion/xdg-desktop-portal-wlr/commit/c613a8bc7cfb.patch";
              hash = "sha256-YFRD4ilF99JFGmLd6oPFb/ddatkTeHEC6TIVBg4l6Xg=";
            })
          ];
        });
      })
    ];

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
        config = {
          common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
        # wlr.enable already adds xdg-desktop-portal-wlr. Listing it here as
        # well creates duplicate systemd user-unit links when it is overlaid.
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];

        # https://github.com/NixOS/nixpkgs/pull/179204
        # gtkUsePortal = true;
      };
    };
  };
}
