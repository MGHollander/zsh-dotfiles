#!/usr/bin/env bash

source "$(dirname "$0")/../.common"

# TODO Add support for other file locations like docroot/sites/
DEV_SERVICES_FILE="development.services.yml"

log "Add twig.config to development.services.yml."

WEBROOT=$1
if [ -z "$WEBROOT" ]; then
    WEBROOT=$(getWebRoot)
fi

SITES_DIR="$WEBROOT/sites"
if [ -d "$SITES_DIR" ]; then
    DEV_SERVICES_FILE="$SITES_DIR/$DEV_SERVICES_FILE"
fi

if [ ! -f "$DEV_SERVICES_FILE" ]; then
    log_warning "$DEV_SERVICES_FILE not found."
    exit;
fi

if [ "$(! grep -q twig.config "$DEV_SERVICES_FILE")" ]; then
    sed -i '' '7i\
\  twig.config:\
\    cache: false\
\    debug: true
' "$DEV_SERVICES_FILE" || { log_error "Failed to add twig.config to development.services.yml."; exit; }

    log_success "Successfully added twig.config to development.services.yml."

    log "Rebuild Drupal caches."
    drush cr
else
    log_warning "twig.config already exists. Double check the content to make sure it is configured as needed."
    cat "$DEV_SERVICES_FILE"
fi
