#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

SCRIPT_DIR=`dirname $0`
SCRIPT_NAME=`basename $0`

# Test command:
# rm -rf dotfiles && bash ~/dotfiles/oneshoe/create-project.sh git@gitlab.com:MGHollander/dotfiles.git --no-database
# rm -rf drupal8-training && bash ~/dotfiles/oneshoe/create-project.sh git@gitlab.com:MGHollander/drupal8-training.git -b 13-website-header --no-database

# TODO:
# - Add posibility to add files to the Drupal files folder

function usage() {
    echo -e "\033[33mUsage:\033[0m"
    echo -e "  $SCRIPT_NAME [options] [--] <repo>"
    echo -e ""
    echo -e "\033[33mArguments:\033[0m"
    echo -e "\033[32m  repo                                 \033[0m  Git repository"
    echo -e ""
    echo -e "\033[33mOptions:\033[0m"
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
            exit 0
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
        -*|--*=) # unsupported flags
            echo -e "\033[31mError: Unsupported flag $1\033[0m" >&2
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

if [ -z $GIT_REPO ]; then
    echo -e "\033[31mPlease provide a Git repository\033[0m"
    echo ""
    usage
    exit 2
fi

if [ -z $PROJECT_NAME ]; then
    PROJECT_NAME=`echo $GIT_REPO | sed -n 's#.*/\([^.]*\)\.git#\1#p'`
fi

BRANCH_COMMAND=""
if [ $BRANCH ]; then
    BRANCH_COMMAND="-b $BRANCH"
fi

# TODO Make the checkout optional?
# TODO Add check to see if git is installed
log "Checkout project"
git clone $GIT_REPO $PROJECT_NAME $BRANCH_COMMAND

if [ $? -gt 0 ]; then
    exit 4
fi

# TODO Add check to see if valet-plus is installed or create db without valet-plus
# TODO Add check to see if db creation succeeded
# TODO Check if database exists and ask if it should be replaced
# TODO Add posibility to import a database
if [ -z $NO_DATABASE ]; then
    if [ -z $DATABASE_NAME ]; then
        DATABASE_NAME=$PROJECT_NAME
    fi

    log "Create database"
    valet db create $PROJECT_NAME
fi

log "Go to project root folder"
cd $PROJECT_NAME/

log "Look for the webroot folder"

if [ -d "./web" ]; then
    WEBROOT="./web"
elif [ -d "./docroot" ]; then
    WEBROOT="./docroot"
elif [ -d "./sites" ]; then
    WEBROOT="."
fi

# TODO find a way to check if the webroot script works.
if [ -z $WEBROOT ]; then
    echo -e "\033[31mCouldn't find the webroot folder\033[0m"
    exit 5
fi

# TODO add checks to determine the CMS / framework and add a settings file for other tools
bash $SCRIPT_DIR/create-drupal-settings-file.sh $WEBROOT $PROJECT_NAME

if [ $? -gt 0 ]; then
    exit 6$?
fi

bash $SCRIPT_DIR/copy-drupal-local-settings-file.sh $WEBROOT

# TODO make clean install optional
if [ -f scripts/clean-install.sh ]; then
    log "Run clean install"
    bash scripts/clean-install.sh
else
    echo -e "\033[33mNo clean install script to run\033[0m";
fi

# TODO make the valet link domain configurable
# TODO check if the domain link already exists and ask if it needs to be replaced
if [ -z $NO_LINK ]; then
    log "Link project to valet"

    cd $WEBROOT
    valet link $PROJECT_NAME

    VALET_DOMAIN=`valet domain`

    echo -e "\033[32mProject link set succesfully\033[0m"
    echo "You can visit the project at http://${PROJECT_NAME}.${VALET_DOMAIN}"
fi

log "Project creation finished"
