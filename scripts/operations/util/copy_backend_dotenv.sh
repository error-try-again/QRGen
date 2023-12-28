#!/usr/bin/env bash

set -euo pipefail

#######################################
# Function to copy the updated .env file to the backend directory
# Globals:
#   BACKEND_DIR
# Arguments:
#  None
#######################################
copy_updated_dotenv() {
   cp ".env" "$BACKEND_DIR"
}
