{
  ...
}:

final: prev: {
  brave = prev.brave.override {
    # Keep Chromium on its default OpenGL path. The Vulkan/ANGLE path corrupts
    # hardware-decoded video when Sway exports the output through PipeWire.
    vulkanSupport = false;
  };
}
