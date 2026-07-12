{
  pkgs,
  lib,
}:

pkgs.writeShellApplication {
  name = "backup-persist";

  runtimeInputs = with pkgs; [
    coreutils
    findutils
    gnugrep
    rsync
    util-linux
  ];

  # On NixOS, sudo must resolve to the setuid wrapper in /run/wrappers rather
  # than the unprivileged binary from the Nix store.

  text = ''
    # shellcheck shell=bash

    readonly DEFAULT_SOURCE="/persist"
    readonly DEFAULT_BACKUP_MOUNT="/home/nikola/backup"
    readonly DEFAULT_BACKUP_BASE="/home/nikola/backup/backups/linux"
    readonly BACKUP_PREFIX="nixos-persist-"
    readonly MAX_FILE_SIZE="100M"
    readonly MAX_BACKUPS=5
    readonly LOW_SPACE_BYTES=10737418240

    source_dir=$DEFAULT_SOURCE
    backup_mount=$DEFAULT_BACKUP_MOUNT
    backup_base=$DEFAULT_BACKUP_BASE
    dry_run=0
    skip_cleanup=0
    allow_unencrypted=0
    unprivileged=0
    original_args=("$@")

    usage() {
      cat <<'EOF'
    Usage: backup-persist [OPTIONS]

    Create a selective snapshot of /persist. Files larger than 100 MB and known
    cache, dependency, build, VM, media, and temporary paths are intentionally
    excluded.

    Options:
      --dry-run, -n              Preview the backup without changing any files
      --no-cleanup               Keep all existing snapshots after a real backup
      --allow-unencrypted        Proceed without detected block-device encryption
      --source DIR               Override /persist (primarily for testing)
      --backup-mount DIR         Override the expected backup mount point
      --destination DIR          Override the snapshot base directory
      --unprivileged             Do not elevate with sudo; refused for /persist
      --help, -h                 Show this help message
    EOF
    }

    die() {
      printf 'Error: %s\n' "$*" >&2
      exit 1
    }

    warn() {
      printf 'WARNING: %s\n' "$*" >&2
    }

    confirm() {
      local prompt=$1
      local response

      [[ -t 0 ]] || return 1
      read -r -p "$prompt [y/N] " response || return 1
      [[ $response =~ ^[Yy]$ ]]
    }

    format_size() {
      numfmt --to=iec-i --suffix=B "$1"
    }

    while (( $# > 0 )); do
      case $1 in
        --dry-run|-n)
          dry_run=1
          shift
          ;;
        --no-cleanup)
          skip_cleanup=1
          shift
          ;;
        --allow-unencrypted)
          allow_unencrypted=1
          shift
          ;;
        --source)
          [[ $# -ge 2 ]] || die "--source requires a directory"
          source_dir=$2
          shift 2
          ;;
        --source=*)
          source_dir=''${1#*=}
          [[ -n $source_dir ]] || die "--source requires a directory"
          shift
          ;;
        --backup-mount)
          [[ $# -ge 2 ]] || die "--backup-mount requires a directory"
          backup_mount=$2
          shift 2
          ;;
        --backup-mount=*)
          backup_mount=''${1#*=}
          [[ -n $backup_mount ]] || die "--backup-mount requires a directory"
          shift
          ;;
        --destination)
          [[ $# -ge 2 ]] || die "--destination requires a directory"
          backup_base=$2
          shift 2
          ;;
        --destination=*)
          backup_base=''${1#*=}
          [[ -n $backup_base ]] || die "--destination requires a directory"
          shift
          ;;
        --unprivileged)
          unprivileged=1
          shift
          ;;
        --help|-h)
          usage
          exit 0
          ;;
        --)
          shift
          (( $# == 0 )) || die "positional arguments are not supported"
          ;;
        *)
          die "unknown option: $1"
          ;;
      esac
    done

    if ! source_dir=$(realpath -e -- "$source_dir" 2>/dev/null); then
      die "source directory does not exist"
    fi
    [[ -d $source_dir ]] || die "source is not a directory: $source_dir"

    if ! backup_mount=$(realpath -e -- "$backup_mount" 2>/dev/null); then
      die "backup mount point does not exist"
    fi
    [[ -d $backup_mount ]] || die "backup mount is not a directory: $backup_mount"
    mountpoint -q -- "$backup_mount" || die "backup disk is not mounted at $backup_mount"

    if ! backup_base=$(realpath -m -- "$backup_base" 2>/dev/null); then
      die "could not resolve destination path"
    fi
    [[ $backup_base != / ]] || die "refusing to use / as the destination"

    relative_destination=$(realpath -m --relative-to="$backup_mount" -- "$backup_base")
    if [[ $relative_destination == .. || $relative_destination == ../* || $relative_destination == /* ]]; then
      die "destination must be inside the backup mount: $backup_mount"
    fi

    relative_to_source=$(realpath -m --relative-to="$source_dir" -- "$backup_base")
    if [[ $relative_to_source != .. && $relative_to_source != ../* && $relative_to_source != /* ]]; then
      die "destination must not be inside the source directory"
    fi

    source_device_id=$(stat -c %d -- "$source_dir")
    destination_device_id=$(stat -c %d -- "$backup_mount")
    [[ $source_device_id != "$destination_device_id" ]] ||
      die "source and backup destination are on the same filesystem"

    mount_source=$(findmnt -nro SOURCE --mountpoint "$backup_mount")
    mount_fstype=$(findmnt -nro FSTYPE --mountpoint "$backup_mount")
    mount_options=$(findmnt -nro OPTIONS --mountpoint "$backup_mount")
    [[ -n $mount_source ]] || die "could not identify the backup filesystem"
    case ,$mount_options, in
      *,rw,*) ;;
      *) die "backup filesystem is not mounted read-write" ;;
    esac

    if (( unprivileged )); then
      if [[ $source_dir == /persist || $source_dir == /persist/* ]]; then
        die "--unprivileged cannot be used for /persist"
      fi
    elif (( EUID != 0 )); then
      self_path=$(readlink -f -- "''${BASH_SOURCE[0]}")
      if [[ -x /run/wrappers/bin/sudo ]]; then
        sudo_command=/run/wrappers/bin/sudo
      elif ! sudo_command=$(command -v sudo); then
        die "sudo is required to back up /persist"
      fi
      exec "$sudo_command" -- "$self_path" "''${original_args[@]}"
    fi

    encryption_state=unknown
    block_source=''${mount_source%%\[*}
    if [[ -b $block_source ]]; then
      block_types=$(lsblk -sno TYPE -- "$block_source" 2>/dev/null || true)
      if [[ -n $block_types ]]; then
        if grep -Eq '^[[:space:]]*crypt[[:space:]]*$' <<< "$block_types"; then
          encryption_state=encrypted
        else
          encryption_state=unencrypted
        fi
      fi
    fi

    printf '=== Backup destination ===\n'
    printf 'Mount:      %s\n' "$backup_mount"
    printf 'Device:     %s (%s)\n' "$mount_source" "$mount_fstype"
    printf 'Snapshots:  %s\n' "$backup_base"
    printf 'Max file:   %s (larger files are intentionally skipped)\n' "$MAX_FILE_SIZE"

    if [[ $encryption_state == encrypted ]]; then
      printf 'Encryption: block-device encryption detected\n'
    else
      if [[ $encryption_state == unencrypted ]]; then
        warn "no block-device encryption was detected for $mount_source"
      else
        warn "could not determine whether $mount_source is encrypted"
      fi

      if (( ! dry_run && ! allow_unencrypted )); then
        if ! confirm "Continue with a destination that is not known to be encrypted?"; then
          [[ -t 0 ]] || die "use --allow-unencrypted to acknowledge this risk"
          printf 'Backup cancelled.\n'
          exit 0
        fi
      fi
    fi

    disk_info=$(df -B1 --output=size,used,avail,pcent -- "$backup_mount" | tail -n 1)
    read -r disk_total disk_used disk_avail disk_percent <<< "$disk_info"
    [[ $disk_total =~ ^[0-9]+$ && $disk_used =~ ^[0-9]+$ && $disk_avail =~ ^[0-9]+$ ]] ||
      die "could not read destination disk usage"
    printf 'Disk:       %s total, %s used, %s available (%s used)\n' \
      "$(format_size "$disk_total")" \
      "$(format_size "$disk_used")" \
      "$(format_size "$disk_avail")" \
      "$disk_percent"

    if (( disk_avail < LOW_SPACE_BYTES )); then
      warn "only $(format_size "$disk_avail") is available on the backup disk"
      if (( ! dry_run )) && ! confirm "Continue despite low disk space?"; then
        [[ -t 0 ]] || die "refusing a non-interactive backup with low disk space"
        printf 'Backup cancelled.\n'
        exit 0
      fi
    fi

    backups=()
    refresh_backups() {
      backups=()
      if [[ -d $backup_base ]]; then
        mapfile -t backups < <(
          find "$backup_base" -mindepth 1 -maxdepth 1 -type d -name "''${BACKUP_PREFIX}*" -print |
            LC_ALL=C sort
        )
      fi
    }

    refresh_backups
    printf 'Existing:   %d completed snapshot(s)\n\n' "''${#backups[@]}"

    if (( ! dry_run )); then
      mkdir -p -- "$backup_base"
      exec {lock_fd}>"$backup_base/.backup-persist.lock"
      flock -n "$lock_fd" || die "another backup is already running"
      refresh_backups
    fi

    timestamp=$(date '+%Y-%m-%d_%H-%M-%S.%N')
    backup_name="''${BACKUP_PREFIX}''${timestamp}"
    final_destination="$backup_base/$backup_name"
    partial_destination="$backup_base/.''${backup_name}.partial"

    [[ ! -e $final_destination && ! -e $partial_destination ]] ||
      die "a backup with this timestamp already exists"

    latest_backup=
    if (( ''${#backups[@]} > 0 )); then
      latest_backup=''${backups[''${#backups[@]} - 1]}
    fi

    excludes=(
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

    exclude_args=()
    for pattern in "''${excludes[@]}"; do
      exclude_args+=(--exclude="$pattern")
    done

    rsync_args=(
      --archive
      --hard-links
      --acls
      --xattrs
      --numeric-ids
      --one-file-system
      --max-size="$MAX_FILE_SIZE"
      --human-readable
      --info=progress2
      --stats
      --verbose
      --mkpath
    )

    if [[ -n $latest_backup ]]; then
      rsync_args+=(--link-dest="$latest_backup")
      printf 'Link base:  %s\n' "$(basename -- "$latest_backup")"
    fi

    partial_created=0
    report_partial_backup() {
      local status=$?
      if (( status != 0 && partial_created )); then
        warn "backup failed; incomplete data remains at $partial_destination"
      fi
    }
    trap report_partial_backup EXIT

    if (( dry_run )); then
      rsync_args+=(--dry-run)
      rsync_destination="$final_destination/"
      printf 'Dry run:    %s/ -> %s\n\n' "$source_dir" "$final_destination"
    else
      mkdir -- "$partial_destination"
      partial_created=1
      rsync_destination="$partial_destination/"
      printf 'Backing up: %s/ -> %s\n\n' "$source_dir" "$final_destination"
    fi

    rsync \
      "''${rsync_args[@]}" \
      "''${exclude_args[@]}" \
      "''${source_dir%/}/" \
      "$rsync_destination"

    if (( dry_run )); then
      trap - EXIT
      printf '\nDry run complete. No files, directories, or backups were changed.\n'
      exit 0
    fi

    current_mount_source=$(findmnt -nro SOURCE --mountpoint "$backup_mount")
    [[ $current_mount_source == "$mount_source" ]] ||
      die "backup mount changed while rsync was running; leaving the partial snapshot in place"

    mv -- "$partial_destination" "$final_destination"
    partial_created=0
    sync -f -- "$final_destination"
    trap - EXIT
    printf '\nBackup complete: %s\n' "$final_destination"

    refresh_backups
    backup_count=''${#backups[@]}
    if (( skip_cleanup )); then
      printf 'Retention cleanup skipped (%d snapshot(s) retained).\n' "$backup_count"
      exit 0
    fi

    if (( backup_count <= MAX_BACKUPS )); then
      printf 'Retention: %d/%d snapshots retained.\n' "$backup_count" "$MAX_BACKUPS"
      exit 0
    fi

    excess=$((backup_count - MAX_BACKUPS))
    printf '\n%d old snapshot(s) can be removed now that the new backup succeeded:\n' "$excess"
    for ((i = 0; i < excess; i++)); do
      printf '  - %s\n' "$(basename -- "''${backups[$i]}")"
    done

    if ! confirm "Delete these old snapshots?"; then
      printf 'Old snapshots retained.\n'
      exit 0
    fi

    for ((i = 0; i < excess; i++)); do
      candidate=''${backups[$i]}
      candidate_parent=$(realpath -e -- "$(dirname -- "$candidate")")
      candidate_name=$(basename -- "$candidate")

      [[ $candidate_parent == "$backup_base" ]] || die "unsafe cleanup path: $candidate"
      [[ $candidate_name == "$BACKUP_PREFIX"* ]] || die "unsafe cleanup name: $candidate_name"
      [[ -d $candidate && ! -L $candidate ]] || die "refusing to remove a non-directory snapshot"

      printf 'Deleting %s...\n' "$candidate_name"
      rm -rf --one-file-system -- "$candidate"
    done

    printf 'Retention cleanup complete; %d snapshots retained.\n' "$MAX_BACKUPS"
  '';

  meta = with lib; {
    description = "Create selective, versioned backups of /persist";
    mainProgram = "backup-persist";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
