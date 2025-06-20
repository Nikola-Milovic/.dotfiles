{
  channels,
  ...
}: final: prev: {
  calibre = prev.calibre.overrideAttrs (oldAttrs: {
    doInstallCheck = false;
  });
}