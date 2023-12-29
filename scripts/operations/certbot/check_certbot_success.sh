#!/usr/bin/env bash

set -euo pipefail

#######################################
# Checks the certbot logs for key strings and restarts services accordingly
# This ensures that services go live after a certificate renewal
# Arguments:
#  None
# Returns:
#   0 ...
#   1 ...
#######################################
function check_certbot_success() {
  local certbot_logs
  certbot_logs=$(docker compose logs certbot)
  echo "Certbot logs: ${certbot_logs}"

  # Check for specific messages indicating certificate renewal success or failure
  if [[ ${certbot_logs} == *'Certificate not yet due for renewal'* ]]; then
    echo "Certificate is not yet due for renewal."
    return 0
  elif [[ ${certbot_logs} == *'Renewing an existing certificate'* ]]; then
    echo "Certificate renewal successful."
    restart_services
    return 0
  elif [[ ${certbot_logs} == *'Successfully received certificate.'* ]]; then
    echo "Certificate creation successful."
    restart_services
    return 0
  else
    echo "Certbot process failed."
    return 1
  fi
}
