#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

SCRIPT_NAME=`basename $0`

function usage() {
    echo -e "\033[33mUsage:\033[0m"
    echo "  $SCRIPT_NAME <path_to_webroot> <database_name>"
}

WEBROOT=$1

if [ -z $WEBROOT ]; then
    echo -e "\033[31mPlease provide a path to the webroot\033[0m"
    echo ""
    usage
    exit 1
fi

DATABASE_NAME=$2

if [ -z $DATABASE_NAME ]; then
    echo -e "\033[31mPlease provide a database name\033[0m"
    echo ""
    usage
    exit 2
fi

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
    echo -e "\033[32mSettings file created\033[0m";
else
    echo -e "\033[31mCouldn't create settings file\033[0m"
    exit 3
fi

chmod 777 $SETTINGS_FILE

log "Add database details to settings file"

echo "" >> $SETTINGS_FILE
if [ 0 -gt $? ]; then
    echo -e "\033[31mCouldn't write in settings file\033[0m"
    exit 4
fi

if [ 0 -eq $? ]; then
    # TODO Make the database details dynamic
    echo "\$databases['default']['default'] = array (
  'database' => '${DATABASE_NAME}',
  'username' => 'root',
  'password' => 'root',
  'host' => 'localhost',
  'driver' => 'mysql',
);" >> $SETTINGS_FILE
else
    echo -e "\033[31mCouldn't write in settings file\033[0m";
    exit 3
fi

echo -e "\033[32mDatabase details have been added to the settings file\033[0m"

chmod 644 $SETTINGS_FILE;
