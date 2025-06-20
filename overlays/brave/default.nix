{
  ...
}:

final: prev: {
  brave = prev.brave.override {
    vulkanSupport = true;
    commandLineArgs = "--enable-features=AcceleratedVideoDecodeLinuxGL,VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE";
  };
}
