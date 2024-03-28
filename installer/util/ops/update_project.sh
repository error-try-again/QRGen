#!/usr/bin/env bash

set -euo pipefail

#######################################
# Updates the project using git pull and stashing any changes
# Arguments:
#  None
#######################################
update_project() {
  local response
  read -r -p "Do you want to update the project? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    git stash
    git pull
  else
    echo "Skipping update"
  fi
}