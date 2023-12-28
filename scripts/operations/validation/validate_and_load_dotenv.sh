#!/usr/bin/env bash

set -euo pipefail

set -euo pipefail
#######################################
# Function to check .env file availability and load it
# Arguments:
#  None
#######################################
validate_and_load_dotenv() {
  if [[ ! -f .env ]]; then
    echo "Error: .env file not found" >&2
    exit 1
  else
    source .env
  fi
}
