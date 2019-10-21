#!/usr/bin/env bash

SCRIPT_NAME=`basename $0`

function usage() {
    echo -e "\033[33mUsage:\033[0m"
    echo "  $SCRIPT_NAME <path_to_webroot>"
}

WEBROOT=$1

if [ -z $WEBROOT ]; then
    echo -e "\033[31mPlease provide a path to the webroot\033[0m"
    echo ""
    usage
    exit 1
fi

SITES_PATH="${WEBROOT}/sites"
SETTINGS_LOCAL_FILE="${SITES_PATH}/default/settings.local.php"

echo "Copy the example local settings file"

# TODO Confirm if the file can be replaced
if [ -f $SETTINGS_LOCAL_FILE ]; then
    echo "There is a local settings file present. Remove it."

    chmod 777 "$SETTINGS_LOCAL_FILE"
    rm "$SETTINGS_LOCAL_FILE"
fi

cp "${SITES_PATH}/example.settings.local.php" $SETTINGS_LOCAL_FILE

if [ 0 -eq $? ]; then
    echo -e "\033[32mLocal settings file created\033[0m";
else
    echo -e "\033[31mCouldn't create local settings file\033[0m"
    exit 1
fi

chmod 777 $SETTINGS_LOCAL_FILE

echo "" >> $SETTINGS_LOCAL_FILE
if [ 0 -gt $? ]; then
    echo -e "\033[31mCouldn't write in local settings file\033[0m"
    exit 2
fi

if [ 0 -eq $? ]; then
    # TODO Make the devl domain dynamic
    echo "\$settings['trusted_host_patterns'] = [
  '\.valet$',
];" >> $SETTINGS_LOCAL_FILE
else
    echo -e "\033[31mCouldn't write in local settings file\033[0m";
    exit 3
fi

echo -e "\033[32mTrusted host pattern has been added to the local settings file\033[0m"

chmod 644 $SETTINGS_LOCAL_FILE;
