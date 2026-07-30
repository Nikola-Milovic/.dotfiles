{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cliproxyapi";
  version = "7.2.104";

  src = fetchurl {
    url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${finalAttrs.version}/CLIProxyAPI_${finalAttrs.version}_linux_amd64.tar.gz";
    hash = "sha256-mTurs3tt6DFgDw6zFSfKD5ODN+HR+DfVz4RiY6/6lyQ=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 cli-proxy-api "$out/bin/cli-proxy-api"

    runHook postInstall
  '';

  meta = {
    description = "Multi-provider API proxy for AI CLI subscriptions and credentials";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = lib.licenses.mit;
    mainProgram = "cli-proxy-api";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
