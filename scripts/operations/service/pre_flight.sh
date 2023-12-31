#!/usr/bin/env bash

set -euo pipefail

#######################################
# Manages conflicting Docker networks and containers
# Arguments:
#  None
#######################################
function pre_flight() {
  # Remove containers that would conflict with `docker compose up`
  remove_conflicting_containers || {
    print_messages "Failed to remove conflicting containers"
    exit 1
  }

  handle_ambiguous_networks || {
    print_messages "Failed to handle ambiguous networks"
    exit 1
  }
}
