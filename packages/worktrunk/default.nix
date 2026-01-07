{
  lib,
  fetchFromGitHub,
  unstableRustPlatform,
}:

unstableRustPlatform.buildRustPackage (finalAttrs: {
  pname = "worktrunk";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lVA8gemD4djE2OBMrKIXoBZ0dcY4hvo2XZzeVieGbqo=";
  };

  cargoHash = "sha256-1tTX18Y1O0TPisxDZ21X3t+qL/6m2crfbuUPFrQQwfY=";

  # vergen-gitcl in build.rs needs git, but we use VERGEN_IDEMPOTENT to skip
  # actual git operations and fall back to CARGO_PKG_VERSION
  env = {
    VERGEN_IDEMPOTENT = "1";
  };

  # The default syntax-highlighting feature requires tree-sitter (C compilation)
  # which is handled automatically by Nix
  buildFeatures = [ "syntax-highlighting" ];

  # Skip tests - one test (test_get_now_returns_reasonable_timestamp) fails in
  # Nix sandbox due to time-related assumptions
  doCheck = false;

  meta = {
    description = "A CLI for Git worktree management, designed for parallel AI agent workflows";
    homepage = "https://github.com/max-sixty/worktrunk";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "wt";
  };
})
