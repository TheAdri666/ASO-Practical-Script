#!/bin/bash

LOGFILE="$(dirname "$0")/prac.log"

# Function to log messages
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGFILE"
}

# Check if the correct number of arguments is provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <course> <origin_directory> <destination_directory>" | tee -a "$LOGFILE"
  log_message "Error: Incorrect number of arguments."
  exit 1
fi

# Assign arguments to variables
course=$1
origin=$2
destination=$3

# Validate origin directory
if [ ! -d "$origin" ]; then
  echo "Error: Origin directory $origin does not exist." | tee -a "$LOGFILE"
  log_message "Error: Origin directory $origin does not exist."
  exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$destination" ]; then
  mkdir -p "$destination"
  log_message "Created destination directory: $destination"
fi

# Iterate through student directories and copy prac.sh files
for student_dir in "$origin"/*; do
  if [ -d "$student_dir" ]; then
    student=$(basename "$student_dir")
    prac_file="$student_dir/prac.sh"
    if [ -f "$prac_file" ]; then
      cp "$prac_file" "$destination/$student.sh"
      log_message "Copied $prac_file to $destination/$student.sh"
    else
      log_message "Warning: prac.sh not found for student $student."
    fi
  fi
done

log_message "Finished collecting assignments for course $course."
