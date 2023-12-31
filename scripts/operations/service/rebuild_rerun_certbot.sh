#!/usr/bin/env bash

set -euo pipefail

#######################################
# Rebuilds certbot with caching to perform the actual certificate request or renewal.
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function rebuild_and_rerun_certbot() {
  print_messages "Rebuilding and rerunning Certbot without dry-run..."
  if ! docker compose build certbot || ! docker compose up -d certbot; then
    print_messages "Failed to rebuild or run Certbot service."
    return 1
  fi
}
