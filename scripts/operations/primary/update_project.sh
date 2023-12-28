#!/usr/bin/env bash

set -euo pipefail

#######################################
# Moves user changes to stash and pulls latest changes from the remote repository.
# Arguments:
#  None
#######################################
update_project() {
  git stash
  git pull
}
