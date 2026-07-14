{
  channels,
  ...
}:
final: prev: {
  calibre = prev.calibre.overrideAttrs (
    oldAttrs:
    let
      pythonEnv = builtins.head (
        builtins.filter (
          input:
          prev.lib.hasPrefix "python3-3.14" (input.name or "") && prev.lib.hasSuffix "-env" (input.name or "")
        ) oldAttrs.buildInputs
      );
    in
    {
      doInstallCheck = false;

      # calibre 9's build otherwise invokes an unwrapped Python 3.14 while a
      # Python 3.13 dependency has populated PYTHONPATH. Use the complete 3.14
      # environment already provided by the upstream derivation.
      preBuild = (oldAttrs.preBuild or "") + ''
        export PATH="${pythonEnv}/bin:$PATH"
      '';
    }
  );
}
