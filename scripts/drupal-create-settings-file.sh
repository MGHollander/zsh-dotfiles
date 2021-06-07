#!/usr/bin/env bash

source "$(dirname "$0")/../.common"

# TODO Add parameters for db settings (like the params in create-project.sh)
MYSQL_HOST=${MYSQL_HOST:-localhost}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASS=${MYSQL_PASS:-root}

function usage() {
    log_warning "Usage:"
    echo "  $(basename "$0") <path_to_webroot> <database_name>"
}

WEBROOT=$1
DB_NAME=$2

if [ -z "$WEBROOT" ]; then
    log_error "Please provide a path to the webroot."
    echo ""
    usage
    exit 1
fi

if [ -z "$DB_NAME" ]; then
    log_error "Please provide a database name."
    echo ""
    usage
    exit 1
fi

SETTINGS_FILE_PATH="$WEBROOT/sites/default"
SETTINGS_FILE="$SETTINGS_FILE_PATH/settings.php"

log "Copy the default settings file."

# TODO Ask to replace the existing file or stop the script
if [ -f "$SETTINGS_FILE" ]; then
    log_warning "There is a settings file present."
    read -rp "Do you want to replace it? [y/N] "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        chmod 777 "$SETTINGS_FILE"
        rm "$SETTINGS_FILE"
    else
        exit
    fi
fi

cp "$SETTINGS_FILE_PATH/default.settings.php" "$SETTINGS_FILE" || { log_error "Failed to create settings file."; exit 1; }
log_success "Settings file created."

chmod 777 "$SETTINGS_FILE" || { log_error "Failed to set permissions of the settings file."; exit 1; }

log "Add database details to settings file."

echo "
// START (added by drupal-create-settings.sh)
\$databases['default']['default'] = array (
  'database' => '$DB_NAME',
  'username' => '$MYSQL_USER',
  'password' => '$MYSQL_PASS',
  'host' => '$MYSQL_HOST',
  'driver' => 'mysql',
);
// END
" >> "$SETTINGS_FILE" || { log_error "Failed to write the database details to the settings file."; exit 1; }

chmod 644 "$SETTINGS_FILE" || { log_error "Failed to reset permissions of the settings file."; exit 1; }

log_success "Database details have been added to the settings file."
