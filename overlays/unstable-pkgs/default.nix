{ channels, ... }:
final: prev: {
  inherit (channels.unstable)
    brave
    vimPlugins
    wl-gammarelay-rs
    obsidian
    ;
}
