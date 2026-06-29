{
  pkgs,
  lib,
}:

pkgs.writeShellApplication {
  name = "codex-resets";

  text = ''
    exec ${pkgs.python3}/bin/python3 ${./codex-resets.py} "$@"
  '';

  meta = with lib; {
    description = "Show Codex reset credits, expirations, and rate-limit windows";
    mainProgram = "codex-resets";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
