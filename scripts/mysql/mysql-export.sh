#!/usr/bin/env bash

# MySQL / MariaDB Dump Helper
# ===========================
# FEATURES: Progress bar with ETA, support multiple databases (dump into separated files) and password as argument
# SOURCE: https://gist.github.com/o5/8bf57b3e5fa4649a81a4449787ba3691

# REQUIREMENTS:
# =============
# GNU Core Utilities, mysql, mysqldump, pv (https://github.com/icetee/pv)

set -e

echo "Need to rewrite this code first :-)"
exit 1

if [ $# -ne 1 ]; then
  echo 1>&2 "Usage: $0 <DB_PASSWORD>"
  exit 1
fi

DB_USER=username
DB_HOST=localhost
declare -a DB_NAME=("master" "second_db")

export MYSQL_PWD
MYSQL_PWD="$1"

log () {
    time=$(date --rfc-3339=seconds)
    echo "[$time] $1"
}

for database in "${DB_NAME[@]}"; do
    db_size=$(mysql \
        -h "$DB_HOST" \
        -u "$DB_USER" \
        --silent \
        --skip-column-names \
        -e "SELECT ROUND(SUM(data_length) * 1.09) AS \"size_bytes\" \
        FROM information_schema.TABLES \
        WHERE table_schema='$database';"
    )

    dir=$(dirname "$0")
    file="$dir/$database.sql"
    size=$(numfmt --to=iec-i --suffix=B "$db_size")
    log "[INFO] Dumping database '$database' (≈$size) into $file ..."

    mysqldump \
        -h "$DB_HOST" \
        -u "$DB_USER" \
        --compact \
        --databases \
        --dump-date \
        --hex-blob \
        --order-by-primary \
        --quick \
        "$database" \
    | pv --size "$db_size" \
    > "$file"

    log "[INFO] Done."
done
