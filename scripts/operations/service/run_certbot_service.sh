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
function run_certbot_service() {
  print_messages "Running Certbot service..."
  handle_certbot_build_and_caching || {
    print_messages "Building Certbot service failed. Exiting."
    exit 1
  }
  run_certbot_dry_run || {
    print_messages "Running Certbot dry run failed. Exiting."
    exit 1
  }
  rebuild_and_rerun_certbot || {
    print_messages "Rebuilding and rerunning Certbot failed. Exiting."
    exit 1
  }
  wait_for_certbot_completion || {
    print_messages "Waiting for Certbot to complete failed. Exiting."
    exit 1
  }
  check_certbot_success || {
    print_messages "Checking for Certbot success failed. Exiting."
    exit 1
  }
  print_messages "Certbot process completed successfully."
}
