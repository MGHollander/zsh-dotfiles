#!/usr/bin/env bash
source "$(dirname "$0")/../common.sh"

# MySQL / MariaDB Dump Helper
# ===========================
# FEATURES: Progress bar with ETA
# SOURCE: https://gist.github.com/o5/8bf57b3e5fa4649a81a4449787ba3691

# REQUIREMENTS:
# =============
# GNU Core Utilities, mysql, mysqldump, pv (https://github.com/icetee/pv)

# TODO
# - Add proper help documentation
# - Make db name optional and use folder as db name if none is set
# - Check if db exists before export
# - Make db settings configurable
# - Add option for uncompressed export

set -e

if [ $# -ne 1 ]; then
  echo 1>&2 "Usage: $0 <DB_NAME>"
  exit 1
fi

DB_HOST=${DB_HOST:-localhost}
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-root}
DB_NAME="$1"

log "\033[1mStart database export"

db_size=$(mysql \
    -h "$DB_HOST" \
    -u "$DB_USER" \
    -p"$DB_PASS" \
    --silent \
    --skip-column-names \
    -e "SELECT ROUND(SUM(data_length) * 1.09) AS \"size_bytes\" \
    FROM information_schema.TABLES \
    WHERE table_schema='$DB_NAME';"
)

file="./$DB_NAME-$(date +'%F-%H%M%S').sql.gz"

# Converts bytes value to human-readable string [$1: bytes value]
# source: https://unix.stackexchange.com/a/259254
bytesToHumanReadable() {
    local i=${1:-0} d="" s=0 S=("Bytes" "KiB" "MiB" "GiB" "TiB" "PiB" "EiB" "YiB" "ZiB")
    while ((i > 1024 && s < ${#S[@]}-1)); do
        printf -v d ".%02d" $((i % 1024 * 100 / 1024))
        i=$((i / 1024))
        s=$((s + 1))
    done
    echo "$i$d ${S[$s]}"
}

log_text "Export $DB_NAME (~$(bytesToHumanReadable "$db_size")) into $file"

mysqldump \
    -h "$DB_HOST" \
    -u "$DB_USER" \
    -p"$DB_PASS" \
    --compact \
    --databases \
    --dump-date \
    --hex-blob \
    --order-by-primary \
    --quick \
    "$DB_NAME" \
| pv --size "$db_size" \
| gzip -c > "$file"

log "Database exported succesfully"
