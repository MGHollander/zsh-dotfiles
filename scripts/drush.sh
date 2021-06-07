#!/usr/bin/env bash

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

log "Run drush command"
COMMAND="drush"

log "Look for a webroot"
WEBROOT=$(getWebRoot)

if [ -n "$WEBROOT" ]; then
    log_success "Found $WEBROOT"
    COMMAND="$COMMAND --root=$PWD/$WEBROOT"
else
    log_warning "Continue without a webroot"
fi

if [ "$1" == "user:login" ] || [ "$1" == "user-login" ] || [ "$1" == "uli" ]; then
    COMMAND="$COMMAND --no-browser"
    PROJECT_NAME=$(basename "$PWD")

    # The valet domain name can be detected automatically, but then you need to
    # type the root password. I don't want to do that everytime...
    COMMAND="$COMMAND --uri=$PROJECT_NAME.valet"
fi

if hash drush 2>/dev/null; then
    $COMMAND "$@"
else
    log_error "Could not find drush"
fi
