#!/bin/bash

# Destination directory on the external hard drive
DEST_DIR="/media/nikola/BackupDrive/backups"

# Exclude patterns
EXCLUDE_PATTERNS=("node_modules/" ".turbo/" ".next/" ".pnpm-store/" "*cache*" ".npm" ".postgres-data" "*cargo*" "docker" ".steam" "Trash" ".docker" "yarn" "pnpm-store" "unityhub" "backuphdd" "vanja/" "BackupDrive/")

# Construct the --exclude options for rsync
EXCLUDES=()
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
	EXCLUDES+=("--exclude=$pattern")
done

# # Disk space check function
# check_disk_space() {
# 	REQUIRED_SPACE=$(du -s /home/nikola /mnt/hddstorage/files | awk '{sum += $1} END {print sum}')
# 	AVAILABLE_SPACE=$(df "$DEST_DIR" | awk 'NR==2 {print $4}')
#
# 	if ((REQUIRED_SPACE > AVAILABLE_SPACE)); then
# 		echo "Error: Not enough disk space available for the backup." | tee -a "$LOG_FILE"
# 		exit 1
# 	fi
# }
#
# # Check disk space before starting the backup
# check_disk_space

# Backup function with error handling
backup() {
	SOURCE=$1
	DEST=$2
	echo "Starting backup of $SOURCE..."
	rsync -avh --progress "${EXCLUDES[@]}" "$SOURCE" "$DEST"
	if [ $? -ne 0 ]; then
		echo "Error: Backup of $SOURCE failed." | tee -a "$LOG_FILE"
		exit 1
	fi
	echo "Backup of $SOURCE complete." | tee -a "$LOG_FILE"
}

# Backup /home/nikola
backup "/home/nikola/" "$DEST_DIR/linux/"

# Backup /mnt/hddstorage/files
backup "/mnt/hddstorage/files/" "$DEST_DIR/hdd/"

echo "All backups completed!"

# Optional: Email notification (uncomment and configure if needed)
# mail -s "Backup completed" your-email@example.com < "$LOG_FILE"
