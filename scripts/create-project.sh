#!/usr/bin/env bash

# Stop on any error.
set -e

SCRIPT_DIR=$(dirname "$0")

source "$SCRIPT_DIR/../.common"

# Set default variables
MYSQL_HOST=${MYSQL_HOST:-localhost}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASS=${MYSQL_PASS:-root}
MYSQL_CHAR_SET=${MYSQL_CHAR_SET:-utf8mb4}
MYSQL_COLLATE=${MYSQL_COLLATE:-utf8mb4_unicode_ci}

# TODO:
# - Add posibility to add files to the Drupal files folder
# - Override mysql settings as parameters

function usage() {
    log_warning "Usage:"
    echo -e "  $(basename "$0") [options] [--] <repo>"
    echo -e ""
    log_warning "Arguments:"
    echo -e "\033[32m  repo                                 \033[0m  Git repository"
    echo -e ""
    log_warning "Options:"
    echo -e "\033[32m  -h, --help                           \033[0m  Display this help message"
    echo -e "\033[32m  -b, --branch <branch>                \033[0m  Checkout <branch> instead of the remote's HEAD"
    echo -e "\033[32m  -d, --database-name <database-name>  \033[0m  Database name. If none is given then <project-name> is used"
    echo -e "\033[32m  -n, --no-database                    \033[0m  Skip database creation"
    echo -e "\033[32m  -l, --no-link                        \033[0m  Skip valet link"
    echo -e "\033[32m  -p, --project-name <project-name>    \033[0m  Project name. If none is given, then the repository name is used"
}

# https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
    case "$1" in
        -h|--help)
            usage
            exit
            ;;
        -b|--branch)
            BRANCH=$2
            shift 2
            ;;
        -d|--database-name)
            DATABASE_NAME=$2
            shift 2
            ;;
        -l|--no-link)
            NO_LINK=1
            shift 1
            ;;
        -n|--no-database)
            NO_DATABASE=1
            shift 1
            ;;
        -p|--project-name)
            PROJECT_NAME=$2
            shift 2
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*) # unsupported flags
            log_error "Error: Unsupported flag \033[1m$1" >&2
            echo ""
            usage
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

GIT_REPO=$1
if [ -z "$GIT_REPO" ]; then
    log_error "Please provide a Git repository"
    echo ""
    usage
    exit 1
fi

# TODO
#  - Add a check if a project name already exists to prevent that two projects are cloned in the same folder.
#  - Add an option to replace the existing folder by the one that you want to create.
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(echo "$GIT_REPO" | sed -n 's#.*/\([^.]*\)\.git#\1#p')
fi

# TODO Make the checkout optional?
# TODO Add check to see if git is installed
log "Checkout project"
if [ -n "$BRANCH" ]; then
    git clone "$GIT_REPO" "$PROJECT_NAME" -b "$BRANCH" || exit 1
else
    git clone "$GIT_REPO" "$PROJECT_NAME" || exit 1
fi
log_success "Project cloned succesfully"

# TODO Check if database exists and ask if it should be replaced
# TODO Add possibility to import a database
if [ -z "$NO_DATABASE" ]; then
    if [ -z "$DATABASE_NAME" ]; then
        DATABASE_NAME=$PROJECT_NAME
    fi

    log "Create a MySQL database if needed"
    mysql_create_db "$DATABASE_NAME"
fi

log "Go to project root folder"
cd "$PROJECT_NAME/"

# TODO TEST TEST TEST
bash "$SCRIPT_DIR/php-version-check.sh"

# The build script needs to run first, because Drupal 8 and Drupal 7 with a make
# file scaffold files like the default.setting.php. And we need those to
# continue the installation.
if [ -f scripts/build.sh ]; then
    log "Pre-run the build"
    bash scripts/build.sh
else
    log_warning "No build script to pre-run";
fi

log "Look for the webroot folder"
WEBROOT=$(getWebRoot)
if [ -z "$WEBROOT" ]; then
    # TODO add checks to determine the CMS / framework and add a settings file for other tools
    if [ -d "./sites" ]; then
        WEBROOT="."
    fi
fi

if [ -n "$WEBROOT" ]; then
    # TODO add checks to determine the CMS / framework and add a settings file for other tools
    bash "$SCRIPT_DIR/drupal-create-settings-file.sh" "$WEBROOT" "$PROJECT_NAME"
    bash "$SCRIPT_DIR/drupal-copy-local-settings-file.sh" "$WEBROOT"
fi


# TODO make clean install optional
# TODO add a command to import a db from a file instead of running a clean install
if [ -f scripts/clean-install.sh ]; then
    log "Run clean install"
    bash scripts/clean-install.sh
else
    log_warning "No clean install script to run";
fi

# TODO make the valet link domain configurable
# TODO check if the domain link already exists and ask if it needs to be replaced
if [ -z $NO_LINK ]; then
    log "Link project to valet"

    cd "$WEBROOT" || exit 1
    valet link "$PROJECT_NAME"
    cd - || exit 1

    PROJECT_URL="http://$PROJECT_NAME.$(valet tld)"

    log_success "Project link set successfully"
    echo "You can visit the project at $PROJECT_URL"
fi

log "Project creation finished"
