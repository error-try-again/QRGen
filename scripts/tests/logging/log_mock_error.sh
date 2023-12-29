#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Log an error message to a file if it contains a common error signature
# Globals:
#   test_output_dir
# Arguments:
#   1
#######################################
function log_mock_error() {
  local message=$1
  local error_log="${test_output_dir}/error.log"

  # Define common error signatures to catch
  local common_errors=("Error" "Failed" "Cannot" "Denied" "Unbound" "Timeout" "Refused" "Invalid" "Bad" "Unknown" "Not Found" "Not Available" "Not Allowed")

  local error
  for error in "${common_errors[@]}"; do
    if [[ ${message} == *${error}* ]]; then
      local date
      date=$(date +"%Y-%m-%d %H:%M:%S")
      echo "${date}: ${message}" >>"${error_log}"
    fi
  done
}
