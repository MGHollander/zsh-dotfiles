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
    log_text "  $SCRIPT_NAME [options] [--] <file> <database>"
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

log "\033[1mStart database import"

# TODO
# - Add proper help documentation
# - Make db name optional and use folder as db name if none is set
# - Check if db exists before import
# - Make db settings configurable
# - Check extension of the db backup and import based on it (compressed db or not)

if ! hash mysql; then
    log_error "MySQL is not available via the terminal. Please install MySQL to continue..."
    exit 1;
fi

if [ $# -ne 1 ]; then
  log_error "You must specify a file to import"
  usage
  exit 1
fi

FILE="$1"

if [ ! -r "$FILE" ]; then
    log_error "$FILE does not exist or is not readable"
    exit 1
fi

if [ -n "$2" ]; then
    DB_NAME="$2"
else
    DB_NAME=$(basename "$PWD")
fi

# TODO Add delete confirmation...
log "\033[1mDelete and re-create database"

if [ -z "$FORCE" ]; then
    log_warning "Are you sure you want to overwrite \033[4;33m$DB_NAME\033[0;33m? This cannot be undone!"
    read -rp "Continue? [Y/n] " -n 1
    echo # move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Imported aborted"
        exit 1
    fi
fi

mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET $MYSQL_CHAR_SET COLLATE $MYSQL_COLLATE;" || exit 1

log "\033[1mImport database dump"

if hash pv; then
    IMPORT="pv $FILE"
fi

FILE_NAME=$(basename -- "$FILE")
FILE_EXTENSION="${FILE_NAME##*.}"

if [ "$FILE_EXTENSION" == "gz" ]; then
    if hash pv && hash gzip; then
        IMPORT="$IMPORT | gzip -cd"
    elif ! hash pv && hash gzip; then
        IMPORT="gzip -cd $FILE"
    else
        log_error "Cannot import a compressed database, because gzip is not installed..."
        exit 1;
    fi
fi

DATABASE="mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASS $DB_NAME"

if [ -z "$IMPORT" ]; then
    eval "$DATABASE < $FILE" || exit 1
else
    eval "$IMPORT | $DATABASE" || exit 1
fi

log "\033[32mDatabase dump is imported succesfully into \033[4m$DB_NAME"
