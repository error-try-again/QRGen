#!/usr/bin/env bash

set -euo pipefail

#######################################
# Checks whether certs are required, if so, generates them.
# Initializes cert file watcher to watch for changes to the certs.
# Globals:
#   USE_LETSENCRYPT
# Arguments:
#  None
#######################################
function handle_certs() {
  # Handle Let's Encrypt configuration
  if [[ $USE_LETSENCRYPT == "true" ]] || [[ $USE_SELF_SIGNED_CERTS == "true" ]]; then
    # Generate self-signed certificates if they don't exist
    generate_self_signed_certificates
  fi
}
