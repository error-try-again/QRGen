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
  print_messages "Configuring default robots.txt..."
  cat <<- EOF > "${ROBOTS_FILE}"
User-agent: *
Disallow:
EOF
  print_messages "Default robots.txt created."
}
