{
  lib,
  fetchFromGitHub,
  unstableRustPlatform,
}:

unstableRustPlatform.buildRustPackage (finalAttrs: {
  pname = "worktrunk";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rkQ0FBKxlcqzUadNn9sdvyiLk2j40LrlunAZHx6UzxI=";
  };

  cargoHash = "sha256-8AhwP5kDvwbNkzSWZFyag8A/UQMABPVeuFvJ754maRI=";

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
