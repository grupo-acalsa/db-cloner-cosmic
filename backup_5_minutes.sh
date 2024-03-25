#!/bin/bash

# 🐽 Get the absolute path of the script's directory in execution
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 🐏 Load environment variables from the .env file
if [ -f "$script_dir/.env" ]; then
  export $(cat "$script_dir/.env" | xargs)
fi

# 🐐 Get the current date in YMD format (year, month, day)
current_date=$(date +"%Y%m%d%H%M%S")

# 🦙 Backup file name
backupFileName="acalsa_restauracion.sql"

# 🦒 Daily backups directory 📂
backupDirectory="$script_dir/backups_daily"

# 🐘 Create the daily backups directory if it doesn't exist
mkdir -p "$backupDirectory"

# 🦣 Get the current year and month
current_year=$(date +"%Y")
current_month=$(date +"%m")
current_day=$(date +"%d")
current_hour=$(date +"%H")
current_minute=$(date +"%M")

# 🦏 Create the year directory if it doesn't exist
year_directory="$backupDirectory/$current_year"
mkdir -p "$year_directory"

# 🦛 Create the month directory if it doesn't exist
month_directory="$year_directory/$current_month"
mkdir -p "$month_directory"

# 🐘 Create the day directory if it doesn't exist
day_directory="$month_directory/$current_day"
mkdir -p "$day_directory"

# 🐏 Create the hour directory if it doesn't exist
hour_directory="$day_directory/$current_hour"
mkdir -p "$hour_directory"

# 🦒 Create the minute directory if it doesn't exist
minute_directory="$hour_directory/$current_minute"
mkdir -p "$minute_directory"

# 🐀 Backup the database 🗃️
mysqldump --no-tablespaces -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE_EXPORT" -h 107.180.51.205  > "$minute_directory/$backupFileName"

sleep 120

mysql -u root -p "$LOCAL_DATABASE" < "$minute_directory/$backupFileName"
