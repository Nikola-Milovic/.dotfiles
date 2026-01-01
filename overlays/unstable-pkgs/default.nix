{ channels, ... }:
final: prev: {
  inherit (channels.unstable)
    vimPlugins
    wl-gammarelay-rs
    obsidian
    rustdesk
    ;

  # Expose unstable Rust toolchain for packages requiring newer Rust versions
  unstableRustPlatform = channels.unstable.rustPlatform;
}
