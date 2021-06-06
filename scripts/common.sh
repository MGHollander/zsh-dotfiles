#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$0")
CONFIG_FILE="$SCRIPT_DIR/../.config"

if [ -e "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Bash colors and formatting
# https://misc.flogisoft.com/bash/tip_colors_and_formatting

function log() {
  echo -e "\033[34m[$(date +'%F %T')]\033[0m $1\033[0m"
}

function log_error() {
    echo -e "\033[31m$1\033[0m"
}

function log_success() {
    echo -e "\033[32m$1\033[0m"
}

function log_text() {
    echo -e "$1\033[0m"
}

function log_warning() {
    echo -e "\033[33m$1\033[0m"
}

# Converts bytes value to human-readable string [$1: bytes value]
# Source: https://unix.stackexchange.com/a/259254
function bytesToHumanReadable() {
    local i=${1:-0} d="" s=0 S=("Bytes" "KiB" "MiB" "GiB" "TiB" "PiB" "EiB" "YiB" "ZiB")
    while ((i > 1024 && s < ${#S[@]}-1)); do
        printf -v d ".%02d" $((i % 1024 * 100 / 1024))
        i=$((i / 1024))
        s=$((s + 1))
    done
    echo "$i$d ${S[$s]}"
}

function getWebRoot() {
    for DIR in "${WEBROOT_POSSIBILITIES[@]:-("web")}"; do
        if [ -d "./$DIR" ]; then
            echo "$DIR"
            break
        fi
    done
}
