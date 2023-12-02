#!/usr/bin/env bash

#######################################
# Creates a directory if it doesn't exist.
# Arguments:
#   1
#######################################
create_directory() {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
    echo "$directory created."
  else
    echo "$directory already exists."
  fi
}
