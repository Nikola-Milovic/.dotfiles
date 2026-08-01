{ zellijPkgs }:
let
  zellijPackage = zellijPkgs.zellij;
  # Zellij embeds precompiled built-in plugins, so rebuild the status bar WASM
  # with the extra quit-prefix hint before building the host binary.
  rustVersion = "1.91.1";
  bootstrapRust =
    zellijPkgs.callPackage "${zellijPkgs.path}/pkgs/development/compilers/rust/bootstrap.nix"
      {
        version = rustVersion;
        hashes = {
          x86_64-unknown-linux-gnu = "1c955c040dd087e4751d15588ddec288b4208bea16f8ec5046c164877e55fff7";
          aarch64-apple-darwin = "f6727c9ab64a5b2a15623f29a023faf0c6a6aeb1347d102b88d595e5c1d9beae";
        };
      };
  wasiStdArchive = zellijPkgs.fetchurl {
    url = "https://static.rust-lang.org/dist/2025-11-10/rust-std-${rustVersion}-wasm32-wasip1.tar.xz";
    hash = "sha256-cO6Ag3OpIQrEnSCLDNGfgxL0Dtwlb4QBjz1CKZk07SY=";
  };
  wasiStd =
    zellijPkgs.runCommand "rust-std-wasm32-wasip1-${rustVersion}"
      {
        nativeBuildInputs = [ zellijPkgs.xz ];
      }
      ''
        mkdir -p "$out/lib/rustlib"
        tar -xf ${wasiStdArchive}
        cp -r \
          rust-std-${rustVersion}-wasm32-wasip1/rust-std-wasm32-wasip1/lib/rustlib/wasm32-wasip1 \
          "$out/lib/rustlib/"
      '';
  rustcWithWasiUnwrapped = bootstrapRust.rustc-unwrapped.overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      cp -r ${wasiStd}/lib/rustlib/wasm32-wasip1 "$out/lib/rustlib/"
    '';
  });
  statusBarRustPlatform = zellijPkgs.makeRustPlatform {
    cargo = bootstrapRust.cargo;
    rustc = zellijPkgs.wrapRustc rustcWithWasiUnwrapped;
  };
  statusBar = statusBarRustPlatform.buildRustPackage {
    pname = "zellij-status-bar";
    inherit (zellijPackage) version src cargoDeps;
    patches = [ ./show-session-quit-hint.patch ];
    buildPhase = ''
      runHook preBuild
      cargo build --offline --release --package status-bar --target wasm32-wasip1
      runHook postBuild
    '';
    doCheck = false;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp target/wasm32-wasip1/release/status-bar.wasm "$out/"
      runHook postInstall
    '';
  };
in
zellijPackage.overrideAttrs (oldAttrs: {
  postPatch = (oldAttrs.postPatch or "") + ''
    cp ${statusBar}/status-bar.wasm zellij-utils/assets/plugins/status-bar.wasm
  '';
})
