{
  inputs,
  mkShell,
  pkgs,
  ...
}:
let
in
mkShell {
  packages = with pkgs; [
    go
    gopls
    golangci-lint-langserver
    golangci-lint
    gofumpt
    goimports
    gomodifytags
  ];

  shellHook = '''';
}
