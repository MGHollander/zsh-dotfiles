#!/usr/bin/env bash

COMMAND="drush"

if [ -d "./web" ]; then
    COMMAND="$COMMAND --root=$PWD/web"
elif [ -d "./docroot" ]; then
    COMMAND="$COMMAND --root=$PWD/docroot"
elif [ ! -d "./sites" ]; then
    echo -e "\033[31mCouldn't find the webroot folder\033[0m"
    exit 1
fi

if [ "$1" == "uli" ]; then
    COMMAND="$COMMAND --no-browser"

    PROJECT_NAME=`basename $PWD`

    # The valet domain name can be detected automatically, but than you need do type the root password. I don't want to do that everytime...
    COMMAND="$COMMAND --uri=$PROJECT_NAME.valet"
fi

$COMMAND $@
