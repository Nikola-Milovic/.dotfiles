{
  pkgs,
  stdenv,
  lib,
}:

pkgs.writeShellApplication {
  name = "backup-persist";

  # Ensure that rsync is available at runtime.
  runtimeInputs = [ pkgs.rsync ];

  meta = with lib; {
    description = "Backup script to backup EVERYTHING from /persist excluding junk files like node modules, caches, ISO images, and more.";
    mainProgram = "backup-persist";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };

  # Disable the check phase.
  checkPhase = "";

  text = ''
            #!/usr/bin/env bash
            set -euo pipefail

        		DATETIME=$(date "+%Y-%m-%d_%H:%M:%S")

            # Define source and destination directories.
            SRC="/persist/"
            DEST="/home/nikola/backup/backups/linux/nixos-persist-''${DATETIME}/"

            # List of patterns to exclude.
            EXCLUDES=(
              ".cache"
    					".turbo"
    					"node_modules"
    					"shows"
    					".go"
    					".direnv"
    					".mypy_cache"
    					".venv"
    					"overlay2"
    					"*.img"
    					"docker/volumes*"
    					"libvirt"
    					"*.qcow2"
    					".vagrant"
    					"*.iso"
            )

            # Build the --exclude arguments.
            EXCLUDE_ARGS=()
            for pattern in "''${EXCLUDES[@]}"; do
              EXCLUDE_ARGS+=(--exclude="$pattern")
            done

            echo "Starting backup from ''${SRC} to ''${DEST}..."
            sudo rsync --max-size=50M -av "''${EXCLUDE_ARGS[@]}" "$SRC" "$DEST"
            echo "Backup complete."
  '';
}
