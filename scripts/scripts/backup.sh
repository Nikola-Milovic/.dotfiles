#!/bin/bash

# Destination directory on the external hard drive
DEST_DIR="/media/nikola/One Touch/backups"

# Exclude patterns
EXCLUDE_PATTERNS=("node_modules/" ".turbo/" ".next/" ".pnpm-store/" "*cache*" ".postgres-data")

# Construct the --exclude options for rsync
EXCLUDES=()
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
	EXCLUDES+=("--exclude=$pattern")
done

# Backup /home/nikola to the linux directory on the external drive
# Uncomment the next lines if you want to backup /home/nikola too
#echo "Starting backup of /home/nikola..."
rsync -avh --progress "${EXCLUDES[@]}" /home/nikola/ "$DEST_DIR/linux/"
#echo "Backup of /home/nikola complete."

# Backup /mnt/hddstorage/files to the hdd directory on the external drive
echo "Starting backup of /mnt/hddstorage/files..."
rsync -avh --progress "${EXCLUDES[@]}" /mnt/hddstorage/files/ "$DEST_DIR/hdd/"
echo "Backup of /mnt/hddstorage/files complete."

echo "All backups completed!"
