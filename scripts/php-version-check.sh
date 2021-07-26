#!/usr/bin/env bash

# Stop on any error.
set -e

source "$(dirname "$0")/../.common"

log "Check for a PHP versions in the composer.json and .lando.yml."

COMPOSER_PHP_VERSION=$(grep '"php":' composer.json 2>/dev/null | cut -f 4 -d'"' | tr -d '>=^~' | grep -o -m 1 -E "[0-9]+\.[0-9]+")
LANDO_PHP_VERSION=$(grep 'php:' .lando.yml 2>/dev/null | cut -f 2 -d ':' | tr -d ''\'' ')
SYSTEM_PHP_VERSION=$(php -v | grep -o -m 1 -E "[0-9]+\.[0-9]+")
PHP_VERSION=""

function switchPhpVersion() {
    PHP_VERSION=$1

    if [ -z "$PHP_VERSION" ]; then
        log_error "Please provide a PHP version."
        return 1
    fi

    # TODO Check if valet is available
    log "Switch to \033[1mPHP ${PHP_VERSION}\033[0m."
    valet use "php@${PHP_VERSION}"
}

if [ -n "${COMPOSER_PHP_VERSION}" ] && [ -n "${LANDO_PHP_VERSION}" ]; then
    if [ "${COMPOSER_PHP_VERSION}" == "${LANDO_PHP_VERSION}" ]; then
        PHP_VERSION="${COMPOSER_PHP_VERSION}"
    elif [ "${COMPOSER_PHP_VERSION}" == "${SYSTEM_PHP_VERSION}" ]; then
        log_warning "The recommended Composer version (\033[1;33mPHP ${COMPOSER_PHP_VERSION}\033[0;33m) matches the active PHP version (\033[1;33mPHP ${SYSTEM_PHP_VERSION}\033[0;33m)."
        log_warning "But Lando recommends \033[1;33mPHP ${LANDO_PHP_VERSION}\033[0;33m). We will keep using \033[1;33mPHP ${SYSTEM_PHP_VERSION}\033[0;33m."
        log_warning "You can switch manually if necessary."
        exit 0
    elif [ "${LANDO_PHP_VERSION}" == "${SYSTEM_PHP_VERSION}" ]; then
        log_warning "The recommended Lando version (\033[1;33mPHP ${LANDO_PHP_VERSION}\033[0;33m) matches the active PHP version (\033[1;33mPHP ${SYSTEM_PHP_VERSION}\033[0;33m)."
        log_warning "But Composer recommends \033[1;33mPHP ${COMPOSER_PHP_VERSION}\033[0;33m). We will keep using \033[1;33mPHP ${SYSTEM_PHP_VERSION}\033[0;33m."
        log_warning "You can switch manually if necessary."
        exit 0
    else
        log_text "We found multiple PHP versions. The active PHP version is \033[1mPHP ${SYSTEM_PHP_VERSION}\033[0m."
        PS3="Please enter your choice: "
        options=("Composer: ${COMPOSER_PHP_VERSION}" "Lando: ${LANDO_PHP_VERSION}" "Active: ${SYSTEM_PHP_VERSION}")
        select opt in "${options[@]}"
        do
            case $opt in
                "Composer: ${COMPOSER_PHP_VERSION}")
                    switchPhpVersion "${COMPOSER_PHP_VERSION}"
                    exit 0
                    ;;
                "Lando: ${LANDO_PHP_VERSION}")
                    switchPhpVersion "${LANDO_PHP_VERSION}"
                    exit 0
                    ;;
                "Active: ${SYSTEM_PHP_VERSION}")
                    log_success "You chose to stay at PHP \033[4m${SYSTEM_PHP_VERSION}\033[0m"
                    exit 0
                    ;;
                *) log_error "Invalid option $REPLY";;
            esac
        done
    fi
elif [ -n "${COMPOSER_PHP_VERSION}" ]; then
    PHP_VERSION="${COMPOSER_PHP_VERSION}"
elif [ -n "${LANDO_PHP_VERSION}" ]; then
    PHP_VERSION="${LANDO_PHP_VERSION}"
fi

if [ "${PHP_VERSION}" == "${SYSTEM_PHP_VERSION}" ]; then
    log_success "The active PHP version (\033[1;32mPHP ${SYSTEM_PHP_VERSION}\033[0;32m) matches the recommanded PHP version."
elif [ -n "${PHP_VERSION}" ]; then
    log_warning "You are using \033[1;33mPHP ${SYSTEM_PHP_VERSION}\033[0;33m, but the recommended PHP version for this project is \033[1;33mPHP ${PHP_VERSION}\033[0;33m."
    log_warning "Would you like to switch to \033[1;33mPHP ${PHP_VERSION}\033[0;33m?"

    read -rp "Continue? [y/N] "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "PHP version will not change."
    else
        switchPhpVersion "${PHP_VERSION}"
    fi
else
    log_warning "No recommended PHP version found in this project. The active PHP version is \033[1;33mPHP ${SYSTEM_PHP_VERSION}\033[0;33m."
fi
