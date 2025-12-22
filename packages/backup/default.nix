{
  pkgs,
  lib,
}:

pkgs.writeShellApplication {
  name = "backup-persist";

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
    DATETIME=$(date "+%Y-%m-%d_%H:%M:%S")

    # Configuration
    SRC="/persist/"
    BACKUP_BASE="/home/nikola/backup/backups/linux"
    BACKUP_PREFIX="nixos-persist-"
    DEST="''${BACKUP_BASE}/''${BACKUP_PREFIX}''${DATETIME}/"
    MAX_BACKUPS=5  # Maximum number of backups to keep

    # Parse arguments
    DRY_RUN=""
    SKIP_CLEANUP=""
    for arg in "$@"; do
      case "$arg" in
        --dry-run|-n) DRY_RUN="--dry-run" ;;
        --no-cleanup) SKIP_CLEANUP="true" ;;
        --help|-h)
          echo "Usage: backup-persist [OPTIONS]"
          echo ""
          echo "Options:"
          echo "  --dry-run, -n  Show what would be transferred without making changes"
          echo "  --no-cleanup   Skip the old backup cleanup prompt"
          echo "  --help, -h     Show this help message"
          exit 0
          ;;
      esac
    done

    # Function to format bytes to human readable
    format_size() {
      local size=$1
      if (( size >= 1073741824 )); then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1073741824}") GB"
      elif (( size >= 1048576 )); then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1048576}") MB"
      elif (( size >= 1024 )); then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1024}") KB"
      else
        echo "$size B"
      fi
    }

    # Check disk space on backup destination
    echo "=== Backup Location Status ==="
    if [[ -d "$BACKUP_BASE" ]]; then
      DISK_INFO=$(df -B1 "$BACKUP_BASE" | tail -1)
      DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
      DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
      DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
      DISK_PERCENT=$(echo "$DISK_INFO" | awk '{print $5}')

      echo "Disk: $(format_size "$DISK_TOTAL") total, $(format_size "$DISK_USED") used, $(format_size "$DISK_AVAIL") available ($DISK_PERCENT used)"

      # Calculate total size of existing backups (can be slow for large backups)
      # Check if any backups exist first to avoid glob failures
      if compgen -G "$BACKUP_BASE/$BACKUP_PREFIX*" > /dev/null 2>&1; then
        echo -n "Calculating existing backups size... "
        BACKUP_SIZE=$(du -sb "$BACKUP_BASE"/"$BACKUP_PREFIX"* 2>/dev/null | awk '{sum += $1} END {print sum+0}')
        echo "$(format_size "$BACKUP_SIZE")"
      else
        echo "No existing backups found."
      fi
      echo ""

      # Warn if disk space is low (less than 10GB available)
      if (( DISK_AVAIL < 10737418240 )); then
        echo "⚠️  WARNING: Low disk space! Only $(format_size "$DISK_AVAIL") available."
        echo ""
        read -rp "Continue anyway? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
          echo "Backup cancelled."
          exit 0
        fi
      fi
    else
      echo "Backup base directory does not exist yet. It will be created."
      echo ""
    fi

    # Check for old backups and offer to clean up
    if [[ -z "$SKIP_CLEANUP" && -d "$BACKUP_BASE" ]]; then
      # Find existing backups sorted by date (oldest first)
      mapfile -t EXISTING_BACKUPS < <(find "$BACKUP_BASE" -maxdepth 1 -type d -name "''${BACKUP_PREFIX}*" 2>/dev/null | sort)
      BACKUP_COUNT=''${#EXISTING_BACKUPS[@]}

      echo "=== Existing Backups ($BACKUP_COUNT found) ==="
      if (( BACKUP_COUNT > 0 )); then
        echo "(Calculating sizes, this may take a moment...)"
        for backup in "''${EXISTING_BACKUPS[@]}"; do
          backup_name=$(basename "$backup")
          backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1 || echo "?")
          echo "  - $backup_name ($backup_size)"
        done
        echo ""
      fi

      if (( BACKUP_COUNT >= MAX_BACKUPS )); then
        EXCESS=$((BACKUP_COUNT - MAX_BACKUPS + 1))
        echo "⚠️  You have $BACKUP_COUNT backups (max: $MAX_BACKUPS)."
        echo "The following $EXCESS oldest backup(s) can be deleted:"
        echo ""

        BACKUPS_TO_DELETE=()
        for ((i=0; i<EXCESS; i++)); do
          backup="''${EXISTING_BACKUPS[$i]}"
          backup_name=$(basename "$backup")
          backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1)
          echo "  - $backup_name ($backup_size)"
          BACKUPS_TO_DELETE+=("$backup")
        done
        echo ""

        read -rp "Delete these old backups? [y/N] " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
          for backup in "''${BACKUPS_TO_DELETE[@]}"; do
            echo "Deleting $(basename "$backup")..."
            rm -rf "$backup"
          done
          echo "Old backups deleted."
          echo ""
        fi
      fi
    fi

    # List of patterns to exclude.
    EXCLUDES=(
      # Caches
      ".cache"
      ".turbo"
      ".mypy_cache"
      ".pytest_cache"
      "__pycache__"
      ".sass-cache"
      ".parcel-cache"
      ".webpack-cache"
      ".next"
      ".nuxt"
      ".svelte-kit"
      "zig-cache"
      ".zig-cache"

      # Package managers / dependencies
      "node_modules"
      ".pnpm-store"
      ".npm"
      ".yarn"
      ".cargo"
      ".rustup"
      ".go"
      ".gradle"
      ".m2"
      "vendor"
      ".bundle"
      "elm-stuff"

      # Build outputs
      "target"
      "dist"
      "build"
      ".stack-work"
      ".cabal"

      # Python
      ".venv"
      "venv"
      ".tox"
      ".eggs"
      "*.egg-info"
      ".hypothesis"
      ".coverage"
      "coverage"

      # Dev tools
      ".direnv"
      ".devenv"
      ".vagrant"

      # Docker / VMs
      "overlay2"
      "docker/volumes*"
      "libvirt"
      "*.qcow2"
      "*.img"
      "*.iso"

      # Media (personal)
      "shows"

      # Misc
      "*.log"
      ".Trash"
      "Trash"
      "tmp"
      ".tmp"
      "__snapshots__"
    )

    # Build the --exclude arguments.
    EXCLUDE_ARGS=()
    for pattern in "''${EXCLUDES[@]}"; do
      EXCLUDE_ARGS+=(--exclude="$pattern")
    done

    # Verify source exists
    if [[ ! -d "$SRC" ]]; then
      echo "Error: Source directory $SRC does not exist!"
      exit 1
    fi

    # Create destination directory
    mkdir -p "$DEST"

    echo "Starting backup from ''${SRC} to ''${DEST}..."
    [[ -n "$DRY_RUN" ]] && echo "(DRY RUN - no changes will be made)"

    sudo rsync \
      --max-size=100M \
      -av \
      --info=progress2 \
      --human-readable \
      $DRY_RUN \
      "''${EXCLUDE_ARGS[@]}" \
      "$SRC" \
      "$DEST"

    echo "Backup complete."
  '';
}
