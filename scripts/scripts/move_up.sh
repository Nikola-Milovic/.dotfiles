#!/bin/bash

# Check if a directory argument is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <subdirectory>"
	exit 1
fi

# Ensure the provided path is a directory
if [ ! -d "$1" ]; then
	echo "Error: $1 is not a directory."
	exit 2
fi

# Navigate to the subdirectory
cd "$1" || exit 3

# Move all visible files and hidden files (but not `.` and `..` directories) to the parent directory
mv * .[^.]* .. 2>/dev/null

# Navigate to the parent directory
cd ..

# Remove the now-empty subdirectory
rmdir "$(basename "$1")"

# Confirm the operation
echo "Contents of $1 have been moved up and the directory has been removed."
