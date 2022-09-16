#!/bin/bash
os="`uname`"
timestamp=$(date +"%m_%d_%Y")
export_file="wp-data/data_$timestamp.sql"

# Export dump
EXPORT_COMMAND='exec mysqldump "$MYSQL_DATABASE" -uroot -p"$MYSQL_ROOT_PASSWORD"'
docker-compose exec db sh -c "$EXPORT_COMMAND" > $export_file

if [[ $os == "Darwin"* ]] ; then
  sed -i '.bak' 1,1d $export_file
else
  sed -i 1,1d $export_file # Removes the password warning from the file
fi
