#!/usr/bin/env bash

set -euo pipefail

#######################################
# Determines whether to use staging or production Let's Encrypt servers
# Depends on whether the dry run was successful
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function run_certbot_dry_run() {
  local certbot_output
  if ! certbot_output=$(docker compose run --rm certbot 2>&1); then
    print_messages "Certbot dry-run command failed."
    print_messages "Output: ${certbot_output}"
    return 1
  fi
  if [[ ${certbot_output} == *'The dry run was successful.'* ]]; then
    print_messages "Certbot dry run successful."
    remove_dry_run_flag
    handle_staging_flags
  else
    print_messages "Certbot dry run failed."
    return 1
  fi
}
