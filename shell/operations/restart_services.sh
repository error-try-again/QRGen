#!/usr/bin/env bash

set -euo pipefail

#######################################
# Restarts the frontend and backend services depending on the release branch
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
restart_services() {
  echo "Restarting backend and frontend services..."
  if [[ $RELEASE_BRANCH = "full-release" ]]; then
    if ! docker compose restart backend || ! docker compose restart frontend; then
      echo "Failed to restart services."
      return 1
    fi
  else
    if ! docker compose restart frontend; then
      echo "Failed to restart services."
      return 1
    fi
  fi
}
