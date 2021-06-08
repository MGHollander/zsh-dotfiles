#!/usr/bin/env bash

# Stop on any error.
set -e

source "$(dirname "$0")/../../.common"

# Set default variables
MYSQL_HOST=${MYSQL_HOST:-localhost}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASS=${MYSQL_PASS:-root}
MYSQL_CHAR_SET=${MYSQL_CHAR_SET:-utf8mb4}
MYSQL_COLLATE=${MYSQL_COLLATE:-utf8mb4_unicode_ci}

# MySQL / MariaDB Dump Helper
# Source: https://gist.github.com/o5/8bf57b3e5fa4649a81a4449787ba3691

function usage() {
    log_text ""
    log_warning "Usage:"
    log_text "  $(basename "$0") [options] [--] <database>"
    log_text ""
    log_warning "Arguments:"
    log_text "\033[32m  <database>                       \033[0m  Database to export (optional, folder name is used if non is provided)"
    log_text ""
    log_warning "Options:"
    log_text "\033[32m  -h, --help                       \033[0m  Display this help message"
    log_text "\033[32m  -r, --result-FILE <result-FILE>  \033[0m  FILE to save the export"
    log_text "\033[32m  -u, --uncompressed               \033[0m  Create an uncompressed export"
    log_text "\033[32m  -H, --host <hostname>            \033[0m  MySQL hostname"
    log_text "\033[32m  -U, --user <username>            \033[0m  MySQL username"
    log_text "\033[32m  -p, --pass <password>            \033[0m  MySQL password"
}

# https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
    case "$1" in
        -h|--help)
            usage
            exit 0
        ;;
        -r|--result-FILE)
            RESULT_FILE=$2
            shift 2
            ;;
        -u|--uncompressed)
            UNCOMPRESSED=1
            shift 1
            ;;
        -H|--host)
            MYSQL_HOST=$2
            shift 2
            ;;
        -U|--user)
            MYSQL_USER=$2
            shift 2
            ;;
        -p|--pass)
            MYSQL_PASS=$2
            shift 2
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*) # unsupported flags
            log_error "Error: Unsupported flag $1" >&2
            echo ""
            usage
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

log "\033[1mStart database export"

mysql_test_connection || exit 1
command -v mysqldump > /dev/null || { log_error "mysqldump not found."; return 1; }

if [ -n "$1" ]; then
    DB_NAME="$1"
else
    DB_NAME=$(basename "$PWD")
fi

mysql_db_exists "$DB_NAME" || { usage; exit 1; }

DB_SIZE=$(mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" "$(_mysql_get_password_option)" \
    --silent --skip-column-names -e "
    SELECT ROUND(SUM(data_length) * 0.91) AS \"size_bytes\"
    FROM information_schema.TABLES
    WHERE table_schema='$DB_NAME';
    "
)

if [ "$DB_SIZE" == "NULL" ]; then
    log_error "Database named \033[1m$DB_NAME\033[0;31m seems to be empty. Aborting export."
    exit 1
fi

RESULT_FILE_EXTENSION="sql"
if command -v gzip > /dev/null && [ -z "$UNCOMPRESSED" ]; then
    RESULT_FILE_EXTENSION="sql.gz"
fi

if [ -z "$RESULT_FILE" ]; then
    RESULT_FILE="./$DB_NAME-$(date +'%F-%H%M%S').$RESULT_FILE_EXTENSION"
fi

log_text "Export $DB_NAME (~$(bytesToHumanReadable "$DB_SIZE")). The progress bar might be inaccurate, because the db size is an estimate."

MYSQL_DUMP="mysqldump -h $MYSQL_HOST -u $MYSQL_USER $(_mysql_get_password_option) \
    --databases --dump-date --hex-blob --order-by-primary --quick \
    $DB_NAME"

if command -v pvs > /dev/null; then
    MYSQL_DUMP="$MYSQL_DUMP | pv --size $DB_SIZE"
fi

if command -v gzip > /dev/null && [ -z "$UNCOMPRESSED" ]; then
    MYSQL_DUMP="$MYSQL_DUMP | gzip -c"
elif ! command -v gzip > /dev/null && [ -n "$UNCOMPRESSED" ]; then
    log_warning "Cannot compress the database export, because gzip is not installed..."
fi

eval "$MYSQL_DUMP > $RESULT_FILE" || exit 1

log "\033[32mDatabase export saved to $RESULT_FILE"
