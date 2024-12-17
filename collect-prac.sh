#!/bin/bash

LOGFILE="$(dirname "$0")/prac.log"

# Function to log messages
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGFILE"
}

printPresentation()
{
  echo "ASO 24/25 - Script Assignment"
  echo "Student name: Adrián Infante Pérez"
  echo ""
  echo "Practical assignment management"
  echo "--------------------------------"
  echo ""
}

printOptions()
{
  opts=(
    "Program collection of assignment solutions"
    "Pack course assignments"
    "See size and date of a course backup file"
    "End program"
  )

  echo ""
  echo "Menu"

  for opt in "${!opts[@]}"
  do
    echo "  $((opt + 1))) ${opts[$opt]}"
  done

  echo ""
}

printMenu()
{
  printPresentation
  printOptions
}

scheduleCollection()
{
  read -p "Course: " course
  read -p "Path containing student accounts: " origin
  read -p "Path to store assignments: " destination

  if [ ! -d "$origin" ]; then
    echo "Error: Origin directory does not exist." | tee -a "$LOGFILE"
    log_message "Error: Origin directory $origin does not exist."
    return
  fi

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
    log_message "Created destination directory: $destination"
  fi

  # Test cron time that executes once per minute, leave commented unless testing.
  # CRON_TIME="* * * * *"
  CRON_TIME="0 8 $(date --date='tomorrow' +\%d) $(date --date='tomorrow' +\%m) *"
  cron_job="$CRON_TIME $(pwd)/store-prac.sh $course $origin $destination >> $(pwd)/$(basename $LOGFILE) 2>&1"

  (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
  log_message "Scheduled cron job for course $course at $CRON_TIME"

  echo "The $course assignment collection process is programmed for tomorrow at 8:00. Origin: $origin. Destination: $destination."
}

packAssignments()
{
  read -p "Course: " course
  read -p "Absolute path of directory with the assignments: " directory

  if [ ! -d "$directory" ]; then
    echo "Error: Directory does not exist." | tee -a "$LOGFILE"
    log_message "Error: Directory $directory does not exist."
    return
  fi

  archive_name="$(pwd)/${course}-$(date '+%y%m%d').tgz"
  tar -czf "$archive_name" -C "$directory" .

  if [ $? -eq 0 ]; then
    log_message "Packed assignments for course $course into $archive_name"
    echo "The assignments have been packed into $archive_name."
  else
    echo "Error: Failed to pack assignments." | tee -a "$LOGFILE"
    log_message "Error: Failed to pack assignments for $course."
  fi
}

getArchiveInfo()
{
  read -p "Course: " course
  archive_name="$(pwd)/${course}-$(date '+%y%m%d').tgz"

  if [ -f "$archive_name" ]; then
    size=$(stat -c%s "$archive_name")
    date=$(date -d "$(stat -c%y "$archive_name")" "+%Y-%m-%d %H:%M:%S")
    echo "The file $archive_name is $size bytes and was created on $date."
    log_message "Displayed info for archive $archive_name"
  else
    echo "Error: Archive does not exist." | tee -a "$LOGFILE"
    log_message "Error: Archive $archive_name does not exist."
  fi
}

readOption()
{
  read -p "Select an option: " opt

  case $opt in
    1)
      scheduleCollection
      ;;
    2)
      packAssignments
      ;;
    3)
      getArchiveInfo
      ;;
    4)
      exit
      ;;
    *)
      echo "Invalid option"
      ;;
  esac

  echo ""
  echo ""
  echo ""
}

main()
{
  while true; do
    printMenu
    readOption
  done;
}

main
