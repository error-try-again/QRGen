#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Enables SSL configuration
# Globals:
#   USE_SSL
#   BACKEND_SCHEME
# Arguments:
#   None
#######################################
function enable_ssl() {
      USE_SSL=true
      BACKEND_SCHEME="https"
}
