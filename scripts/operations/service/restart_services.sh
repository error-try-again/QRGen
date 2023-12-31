#!/usr/bin/env bash

set -euo pipefail

#######################################
# Restarts the frontend and backend services depending on the release branch
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function restart_services() {
  print_messages "Restarting backend and frontend services..."
  if [[ ${RELEASE_BRANCH} == "full-release" ]]; then
    if ! docker compose restart backend || ! docker compose restart frontend; then
      print_messages "Failed to restart services."
      return 1
    fi
  else
    if ! docker compose restart frontend; then
      print_messages "Failed to restart services."
      return 1
    fi
  fi
}
