#!/usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

SCRIPT_NAME=$(basename "$0")

function usage() {
    log_warning "Usage:"
    echo -e "  $SCRIPT_NAME [options] [--] <project>"
    echo -e ""
    log_warning "Arguments:"
    echo -e "\033[32m  project     \033[0m  Project name"
    echo -e ""
    log_warning "Options:"
    echo -e "\033[32m  -h, --help  \033[0m  Display this help message"

}

# https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
    case "$1" in
        -h|--help)
            usage
            exit 0
        ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*|--*=) # unsupported flags
            log_error "Error: Unsupported flag $1" >&2
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

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    log_error "Please provide a project name"
    echo ""
    usage
    exit 1
fi

log "Remove project folder"
if [ ! -d "$PROJECT_NAME" ]; then
    log_error "$PROJECT_NAME is not a project folder"
    exit 2
fi

echo -e "\033[0;33mAre you sure you want to remove \033[4;33m$PROJECT_NAME\033[0;33m? This cannot be undone!\033[0m"
read -p "Continue (yes/no)? " choice
case "$choice" in
    y|Y|[yY][eE][sS] ) ;;
    * ) exit 0 ;;
esac

if sudo rm -rf "$PROJECT_NAME"; then
    log_success "Project folder is removed successfully"
else
    log_error "Cannot remove project folder"
fi

if hash valet 2>/dev/null; then
    log "Remove database"
    valet db drop "$PROJECT_NAME" -y

    log "Remove valet link"
    valet unlink "$PROJECT_NAME"
else
    log_error "Cannot remove database and valet link, because valet is not installed"
fi
