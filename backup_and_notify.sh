#!/bin/bash

# 🐽 Get the absolute path of the script's directory in execution
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 🐏 Load environment variables from the .env file
if [ -f "$script_dir/.env" ]; then
  export $(cat "$script_dir/.env" | xargs)
fi

# 🐐 Get the current date in YMD format (year, month, day)
current_date=$(date +"%Y%m%d")

# 🐪 SendGrid credentials setup 📧
api_key="$SENDGRID_API_KEY"
from_email="backups_$current_date@$ENDPOINT"
to_email="$TO_EMAIL"
subject="Backup Database $current_date"

# 🦙 Backup file name
backupFileName="backup_$current_date.sql.gz"

# 🦒 Daily backups directory 📂
backupDirectory="$script_dir/backups_daily"

# 🐘 Create the daily backups directory if it doesn't exist
mkdir -p "$backupDirectory"

# 🦣 Get the current year and month
current_year=$(date +"%Y")
current_month=$(date +"%m")

# 🦏 Create the year directory if it doesn't exist
year_directory="$backupDirectory/$current_year"
mkdir -p "$year_directory"

# 🦛 Create the month directory if it doesn't exist
month_directory="$year_directory/$current_month"
mkdir -p "$month_directory"

# 🐀 Backup the database and compress it 🗃️
mysqldump --no-tablespaces -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE_EXPORT" | gzip > "$month_directory/$backupFileName"

sleep 30

# 🐹 Database name with the current date 📅
database_name_test="$BACKUP_TEST"

# 🐰 Decompress the backup file and change its name
uncompressedFileName="$month_directory/backup_$current_date.sql.test"
gunzip -c "$month_directory/$backupFileName" > "$uncompressedFileName"

# 🐿️ Restore the database
mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$database_name_test" < "$uncompressedFileName"

sleep 30

# 🦫 Verify that the structure of the restored database is equal to "$database_name" ✅❌
diff_output=$(mysqldiff -u="$MYSQL_USER" -p="$MYSQL_PASSWORD" "$MYSQL_DATABASE_EXPORT" "$uncompressedFileName")

sleep 15

if [ -z "$diff_output" ]; then
  database_verification_result="Se genero el respaldo de la base de datos de la fecha $current_date"
else
  database_verification_result="Warning: The restored database is not equal to the $database_name database. Differences detected:\n$diff_output ❌"
fi

# 🦔 HTML content of the email with a basic template 📧📝
html_body="
<!DOCTYPE html>
<html>
<head>
  <title>🔸🔸🔸🔸🔸🔸 Database Backup 🔸🔸🔸🔸🔸🔸 </title>
</head>
<body>
  <h1>🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘</h1>
  <p>$database_verification_result</p>
</body>
</html>
"

# 🦇 Create a temporary JSON file with the request data 📄
json_file="/tmp/sendgrid_request.json"
cat <<EOF > "$json_file"
{
  "personalizations": [
    {
      "to": [
        {
          "email": "$to_email"
        }
      ],
      "subject": "$subject"
    }
  ],
  "from": {
    "email": "$from_email"
  },
  "content": [
    {
      "type": "text/html",
      "value": "$html_body"
    }
  ],
  "attachments": [
    {
      "content": "$(cat "$month_directory/$backupFileName" | base64 -w 0)",
      "filename": "$backupFileName",
      "type": "application/gzip",
      "disposition": "attachment"
    }
  ]
}
EOF

# 🐻 Configure cURL request to send the email through SendGrid 🚀
curl -X "POST" "https://api.sendgrid.com/v3/mail/send" \
     -H "Authorization: Bearer $api_key" \
     -H "Content-Type: application/json" \
     -d "@$json_file"
