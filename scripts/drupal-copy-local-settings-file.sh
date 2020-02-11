#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

SCRIPT_NAME=`basename $0`

function usage() {
    log_warning "Usage:"
    echo "  $SCRIPT_NAME <path_to_webroot>"
}

WEBROOT=$1

if [ -z $WEBROOT ]; then
    log_error "Please provide a path to the webroot"
    echo ""
    usage
    exit 1
fi

SITES_PATH="${WEBROOT}/sites"
SETTINGS_LOCAL_FILE="${SITES_PATH}/default/settings.local.php"
SETTINGS_LOCAL_EXAMPLE_FILE="${SITES_PATH}/example.settings.local.php"

log "Copy the example local settings file"

# TODO Confirm if the file can be replaced
if [ -f $SETTINGS_LOCAL_FILE ]; then
    log "There is a local settings file present. Remove it."

    chmod 777 "$SETTINGS_LOCAL_FILE"
    rm "$SETTINGS_LOCAL_FILE"
fi

if [ -f $SETTINGS_LOCAL_EXAMPLE_FILE ]; then
  cp $SETTINGS_LOCAL_EXAMPLE_FILE $SETTINGS_LOCAL_FILE

  if [ 0 -eq $? ]; then
      log_success "Local settings file created";
  else
      log_error "Couldn't create local settings file"
      exit 1
  fi
else
   log_warning "There is no local settings example available"
   exit 1
fi

chmod 777 $SETTINGS_LOCAL_FILE

log "Add trusted host patterns to local settings file"

echo "" >> $SETTINGS_LOCAL_FILE
if [ 0 -gt $? ]; then
    log_error "Couldn't write in local settings file"
    exit 2
fi

if [ 0 -eq $? ]; then
    echo "\$settings['trusted_host_patterns'] = ['.*'];" >> $SETTINGS_LOCAL_FILE
else
    log_error "Couldn't write in local settings file";
    exit 3
fi

log_success "Trusted host pattern has been added to the local settings file"

chmod 644 $SETTINGS_LOCAL_FILE;
