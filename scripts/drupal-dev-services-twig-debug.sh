#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

if [ -z $(grep twig.config web/sites/development.services.yml) ]; then
    log "Add twig.config to development.services.yml"
    sed -i '' '7i\
\  twig.config:\
\    cache: false\
\    debug: true
' web/sites/development.services.yml
    log "Rebuild Drupal caches"
    drush cr
fi

