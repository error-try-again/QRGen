#!/usr/bin/env bash

set -euo pipefail

#######################################
# Runs the Certbot service, checks for dry run success, strips the dry run flag,
# and runs the Certbot service again. Finally, restarts the backend and frontend services.
# When running in production, the staging flag is also removed.
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
run_certbot_service() {
  echo "Running Certbot service..."
  build_certbot_service || {
    echo "Building Certbot service failed. Exiting."
    exit 1
  }
  run_certbot_dry_run || {
    echo "Running Certbot dry run failed. Exiting."
    exit 1
  }
  rebuild_and_rerun_certbot || {
    echo "Rebuilding and rerunning Certbot failed. Exiting."
    exit 1
  }
  wait_for_certbot_completion || {
    echo "Waiting for Certbot to complete failed. Exiting."
    exit 1
  }
  check_certbot_success || {
    echo "Checking for Certbot success failed. Exiting."
    exit 1
  }
  echo "Certbot process completed successfully."
}
