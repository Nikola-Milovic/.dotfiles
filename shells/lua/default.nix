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
    lua-language-server
    stylua
  ];
}
