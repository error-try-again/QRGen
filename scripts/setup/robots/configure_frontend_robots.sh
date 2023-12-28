#!/usr/bin/env bash

set -euo pipefail

#######################################
# Create a default robots.txt file with no restrictions
# Globals:
#   None
# Arguments:
#  None
#######################################
function configure_frontend_robots() {
    cat <<- EOF > "${ROBOTS_FILE}"
User-agent: *
Disallow:
EOF
  echo "Default robots.txt created."
}
