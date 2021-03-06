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
    log_text "  $(basename "$0") [options] [--] <file> <database>"
    log_text ""
    log_warning "Arguments:"
    log_text "\033[32m  <file>                       \033[0m  Database export to import"
    log_text "\033[32m  <database>                   \033[0m  Database to import into (optional, folder name is used if non is provided)"
    log_text ""
    log_warning "Options:"
    log_text "\033[32m  -h, --help                   \033[0m  Display this help message"
    log_text "\033[32m  -f, --force                  \033[0m  Force the import"
    log_text "\033[32m  -H, --host <hostname>        \033[0m  MySQL hostname"
    log_text "\033[32m  -U, --user <username>        \033[0m  MySQL username"
    log_text "\033[32m  -p, --pass <password>        \033[0m  MySQL password"
    log_text "\033[32m  -c, --char-set <char-set>    \033[0m  MySQL character set"
    log_text "\033[32m  -C, --collate <collate>      \033[0m  MySQL collation"
}

# https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
    case "$1" in
        -h|--help)
            usage
            exit 0
        ;;
        -f|--force)
            FORCE=1
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
        -c|--char-set)
            MYSQL_CHAR_SET=$2
            shift 2
            ;;
        -C|--collate)
            MYSQL_COLLATE=$2
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

mysql_test_connection || return 1

if [ -z "$1" ]; then
  log_error "You must specify a file to import."
  usage
  exit 1
fi

FILE="$1"

if [ ! -r "$FILE" ]; then
    log_error "$FILE does not exist or is not readable."
    exit 1
fi

if [ -n "$2" ]; then
    DB_NAME="$2"
else
    DB_NAME=$(basename "$PWD")
fi

log "Start database import."
log "Delete and re-create database."

if [ -z "$FORCE" ]; then
    log_warning "Are you sure you want to overwrite \033[1;33m$DB_NAME\033[0;33m? This cannot be undone!"
    read -rp "Continue? [y/N] "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Imported aborted"
        exit 1
    fi
fi

mysql_drop_db "$DB_NAME" || exit 1
mysql_create_db "$DB_NAME" || exit 1

log "Import database dump."

if command -v pv > /dev/null; then
    IMPORT="pv $FILE"
fi

FILE_NAME=$(basename -- "$FILE")
FILE_EXTENSION="${FILE_NAME##*.}"

if [ "$FILE_EXTENSION" == "gz" ]; then
    if command -v pv > /dev/null && command -v gzip > /dev/null; then
        IMPORT="$IMPORT | gzip -cd"
    elif ! command -v pv > /dev/null && command -v gzip > /dev/null; then
        IMPORT="gzip -cd $FILE"
    else
        log_error "Cannot import a compressed database, because gzip is not installed."
        exit 1;
    fi
fi

DATABASE="mysql -h $MYSQL_HOST -u $MYSQL_USER $(_mysql_get_password_option)"

if [ -z "$IMPORT" ]; then
    eval "$DATABASE < $FILE" || exit 1
else
    eval "$IMPORT | $DATABASE" || exit 1
fi

log_success "Database dump is imported succesfully into \033[1m$DB_NAME\033[0;32m."
