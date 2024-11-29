{ channels, ... }:
final: prev: {
  inherit (channels.unstable)
    vimPlugins
    wl-gammarelay-rs
    obsidian
    rustdesk
    ;
}
