#!/usr/bin/env bash

set -euo pipefail

#######################################
# Enable Let's Encrypt flag
# Globals:
#   USE_LETSENCRYPT
# Arguments:
#  None
#######################################
enable_letsencrypt() {
  USE_LETSENCRYPT=true
}
