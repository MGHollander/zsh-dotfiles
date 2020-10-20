#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

DEV_SERVICES_FILE="web/sites/development.services.yml"

log "Add twig.config to development.services.yml"

if [ ! -f $DEV_SERVICES_FILE ]; then
    log_warning "$DEV_SERVICES_FILE not found"
    exit;
fi

if [ -z $(grep twig.config $DEV_SERVICES_FILE) ]; then
    sed -i '' '7i\
\  twig.config:\
\    cache: false\
\    debug: true
' $DEV_SERVICES_FILE || { log_error "Failed to add twig.config to development.services.yml"; exit; }
    log_success "Successfully added twig.config to development.services.yml"

    log "Rebuild Drupal caches"
    drush cr
else
    log_warning "twig.config is already exists. Double check the content to make sure it is configured as needed"
    cat $DEV_SERVICES_FILE
fi
