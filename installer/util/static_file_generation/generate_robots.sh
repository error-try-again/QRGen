#!/usr/bin/env bash

set -euo pipefail

#######################################
# Generates a default robots.txt file.
# Arguments:
#   1
#######################################
generate_robots() {
  local robots_file="${1}"
  print_message "Configuring default robots.txt..."
  cat <<- EOF > "${robots_file}"
User-agent: *
Disallow:
EOF
  print_message "Default robots.txt created."
}