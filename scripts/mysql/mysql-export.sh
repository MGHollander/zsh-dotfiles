#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")

source "$SCRIPT_DIR/../common.sh"
source "$SCRIPT_DIR/mysql-settings.sh"

# Stop on any error.
set -e

# MySQL / MariaDB Dump Helper
# Source: https://gist.github.com/o5/8bf57b3e5fa4649a81a4449787ba3691

function usage() {
    log_text ""
    log_warning "Usage:"
    log_text "  $SCRIPT_NAME [options] [--] <database>"
    log_text ""
    log_warning "Arguments:"
    log_text "\033[32m  <database>                       \033[0m  Database to export (optional, folder name is used if non is provided)"
    log_text ""
    log_warning "Options:"
    log_text "\033[32m  -h, --help                       \033[0m  Display this help message"
    log_text "\033[32m  -r, --result-FILE <result-FILE>  \033[0m  FILE to save the export"
    log_text "\033[32m  -u, --uncompressed               \033[0m  Make an uncompressed export"
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
        -*|--*=) # unsupported flags
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

if ! hash mysql || ! hash mysqldump; then
    log_error "MySQL is not available via the terminal. Please install MySQL to continue..."
    exit 1;
fi

if [ -n "$1" ]; then
    DB_NAME="$1"
else
    DB_NAME=$(basename "$PWD")
fi

DB_EXISTS=$(mysql \
    -h "$MYSQL_HOST" \
    -u "$MYSQL_USER" \
    -p"$MYSQL_PASS" \
    --batch \
    --skip-column-names \
    -e "SHOW DATABASES LIKE '$DB_NAME';" \
    | grep "$DB_NAME" > /dev/null; echo "$?"
)

if [ "$DB_EXISTS" -eq 1 ]; then
    log_error "No database with the name '$DB_NAME' found"
    usage
    exit 1
fi

DB_SIZE=$(mysql \
    -h "$MYSQL_HOST" \
    -u "$MYSQL_USER" \
    -p"$MYSQL_PASS" \
    --silent \
    --skip-column-names \
    -e "SELECT ROUND(SUM(data_length) * 0.91) AS \"size_bytes\" \
    FROM information_schema.TABLES \
    WHERE table_schema='$DB_NAME';"
)

RESULT_FILE_EXTENSION="sql"
if hash gzip && [ -z "$UNCOMPRESSED" ]; then
    RESULT_FILE_EXTENSION="sql.gz"
fi

if [ -z "$RESULT_FILE" ]; then
    RESULT_FILE="./$DB_NAME-$(date +'%F-%H%M%S').$RESULT_FILE_EXTENSION"
fi

log_text "Export $DB_NAME (~$(bytesToHumanReadable "$DB_SIZE"))"

MYSQL_DUMP="mysqldump \
    -h $MYSQL_HOST \
    -u $MYSQL_USER \
    -p$MYSQL_PASS \
    --compact \
    --databases \
    --dump-date \
    --hex-blob \
    --order-by-primary \
    --quick \
    $DB_NAME"

if hash pv; then
    MYSQL_DUMP="$MYSQL_DUMP | pv --size $DB_SIZE"
fi

if hash gzip && [ -z "$UNCOMPRESSED" ]; then
    MYSQL_DUMP="$MYSQL_DUMP | gzip -c"
elif ! hash gzip && [ -n "$UNCOMPRESSED" ]; then
    log_warning "Cannot compress the database export, because gzip is not installed..."
fi

eval "$MYSQL_DUMP > $RESULT_FILE"

log "\033[32mDatabase export saved to $RESULT_FILE"
