#!/usr/bin/env bash

set -euo pipefail

set -euo pipefail
#######################################
# Function to check .env file availability and load it
# Arguments:
#  None
#######################################
function validate_and_load_dotenv() {
  if [[ ! -f .env ]]; then
    print_messages "Error: .env file not found" >&2
    exit 1
  else
    source .env
  fi
}
