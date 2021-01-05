#!/usr/bin/env bash
source "$(dirname "$0")/../common.sh"

set -e

# TODO
# - Add proper help documentation
# - Make db name optional and use folder as db name if none is set
# - Check if db exists before import
# - Make db settings configurable
# - Check extension of the db backup and import based on it (compressed db or not)

if [ $# -ne 2 ]; then
  echo 1>&2 "Usage: $0 <BD_BACKUP_FILE> <DB_NAME>"
  exit 1
fi

DB_HOST=localhost
DB_USER=root
DB_PASS=root

FILE="$1"
DB_NAME="$2"

log "\033[1mStart database import"
log_text "Import $FILE into $DB_NAME"

# echo "$FILE | gzip -cd | mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME"
pv "$FILE" | gzip -cd | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" || exit 1

log_success "Database imported succesfully"

# Import MySQL database with a progress bar
# pv /path/to/[database_dump].sql | mysql -h [host] -u [username] -p[password] [database_name]

# Import compressed MySQL database with a progress bar
# pv /path/to/[database_dump].sql.gz | gzip -cd | mysql -h [host] -u [username] -p[password] [database_name]
