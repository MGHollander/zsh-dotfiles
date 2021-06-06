#!/usr/bin/env bash

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

set -e

log "Check for a PHP versions in the composer.json and .lando.yml and use it if one is available"

COMPOSER_PHP_VERSION=$(grep '"php":' composer.json 2>/dev/null | cut -f 4 -d'"' | tr -d '>=^~')
LANDO_PHP_VERSION=$(grep 'php:' .lando.yml 2>/dev/null | cut -f 2 -d ':' | tr -d ''\'' ')
SYSTEM_PHP_VERSION=$(php -v | grep -o -m 1 -E "[0-9]+\.[0-9]+")
PHP_VERSION=""

if [ -n "${COMPOSER_PHP_VERSION}" ] && [ -n "${LANDO_PHP_VERSION}" ]; then
    if [ "${COMPOSER_PHP_VERSION}" == "${LANDO_PHP_VERSION}" ]; then
        PHP_VERSION="${COMPOSER_PHP_VERSION}"
    else
        log "We found multiple PHP versions. The active PHP version is \033[1m${SYSTEM_PHP_VERSION}\033[0m."
        PS3="Please enter your choice: "
        options=("Composer: ${COMPOSER_PHP_VERSION}" "Lando: ${LANDO_PHP_VERSION}" "Active: ${SYSTEM_PHP_VERSION}")
        select opt in "${options[@]}"
        do
            case $opt in
                "Composer: ${COMPOSER_PHP_VERSION}")
                    log "You chose PHP \033[1m${COMPOSER_PHP_VERSION}\033[0m"
                    PHP_VERSION="${COMPOSER_PHP_VERSION}"
                    break
                    ;;
                "Lando: ${LANDO_PHP_VERSION}")
                    log "You chose PHP \033[1m${LANDO_PHP_VERSION}\033[0m"
                    PHP_VERSION="${LANDO_PHP_VERSION}"
                    break
                    ;;
                "Active: ${SYSTEM_PHP_VERSION}")
                    log_success "You chose to keep using PHP \033[4m${SYSTEM_PHP_VERSION}\033[0m"
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
    log_success "The active PHP version (PHP ${SYSTEM_PHP_VERSION}) matches the recommanded PHP version."
elif [ -n "${PHP_VERSION}" ]; then
    log_warning "The active PHP version differs from the recommended PHP version. Do you want to use \033[4;33mPHP $PHP_VERSION\033[0;33m?"
    read -p "Continue? [y/N] "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "PHP version will not change."
    else
        # TODO Check if valet is available
        log "Switch valet to PHP \033[1m${PHP_VERSION}\033[0m."
        valet use "php@${PHP_VERSION}"
    fi
else
    log_warning "No PHP version found. The active PHP version is \033[4;33m${SYSTEM_PHP_VERSION}\033[0;33m."
fi
