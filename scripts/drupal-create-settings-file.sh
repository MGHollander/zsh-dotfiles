#!/usr/bin/env bash

source "$(dirname "$0")/../.common"

function usage() {
    log_warning "Usage:"
    echo "  $(basename "$0") <path_to_webroot> <database_name>"
}

WEBROOT=$1

if [ -z $WEBROOT ]; then
    log_error "Please provide a path to the webroot"
    echo ""
    usage
    exit 1
fi

DATABASE_NAME=$2

if [ -z $DATABASE_NAME ]; then
    log_error "Please provide a database name"
    echo ""
    usage
    exit 2
fi

# TODO Add parameters for db settings (like the params in create-project.sh)
MYSQL_HOSTNAME=${MYSQL_HOSTNAME:-localhost}
MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}

SETTINGS_FILE_PATH="${WEBROOT}/sites/default"
SETTINGS_FILE="${SETTINGS_FILE_PATH}/settings.php"

log "Copy the default settings file"

# TODO Confirm if the file can be replaced
if [ -f $SETTINGS_FILE ]; then
    echo "There is a settings file present. Remove it."

    chmod 777 "$SETTINGS_FILE"
    rm "$SETTINGS_FILE"
fi

cp "${SETTINGS_FILE_PATH}/default.settings.php" $SETTINGS_FILE

if [ 0 -eq $? ]; then
    log_success "Settings file created";
else
    log_error "Couldn't create settings file"
    exit 3
fi

chmod 777 $SETTINGS_FILE

log "Add database details to settings file"

echo "" >> $SETTINGS_FILE
if [ 0 -gt $? ]; then
    log_error "Couldn't write in settings file"
    exit 4
fi

if [ 0 -eq $? ]; then
    echo "
\$databases['default']['default'] = array (
  'database' => '${DATABASE_NAME}',
  'username' => '${MYSQL_ROOT_USER}',
  'password' => '${MYSQL_ROOT_PASSWORD}',
  'host' => '${MYSQL_HOSTNAME}',
  'driver' => 'mysql',
);" >> $SETTINGS_FILE
else
    log_error "Couldn't write in settings file";
    exit 3
fi

log_success "Database details have been added to the settings file"

chmod 644 $SETTINGS_FILE;
