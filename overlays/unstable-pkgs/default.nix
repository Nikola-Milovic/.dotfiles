{ channels, ... }:
final: prev: {
  inherit (channels.unstable)
    ollama
    ollama-cpu
    ollama-cuda
    ollama-rocm
    ollama-vulkan
    vimPlugins
    wl-gammarelay-rs
    obsidian
    rustdesk
    tailscale
    ;

  # Expose unstable Rust toolchain for packages requiring newer Rust versions
  unstableRustPlatform = channels.unstable.rustPlatform;
}
