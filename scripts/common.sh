#!/usr/bin/env bash

# TODO Add functions for general messages, warnings and errors
function log() {
  echo -e "\033[34m[$(date +'%F %T')] \033[1m$1\033[0m"
}
