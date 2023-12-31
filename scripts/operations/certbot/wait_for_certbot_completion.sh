#!/usr/bin/env bash

set -euo pipefail

#######################################
# Iteratively waits for the certbot docker container to have finished
# Then checks the logs for success or failure and returns accordingly
# Arguments:
#  None
# Returns:
#   0 ...
#   1 ...
#######################################
function wait_for_certbot_completion() {
  local attempt_count=0
  local max_attempts=12
  while ((attempt_count < max_attempts)); do

    local certbot_container_id
    local certbot_status

    certbot_container_id=$(docker compose ps -q certbot)

    #TODO: Clean up this logic
    if [[ -n ${certbot_container_id} ]]; then

      certbot_status=$(docker inspect -f '{{.State.Status}}' "${certbot_container_id}")
      print_messages "Attempt ${attempt_count}"
      print_messages "Certbot container status: ${certbot_status}"

      if [[ ${certbot_status} == "exited" ]]; then
        return 0
    elif   [[ ${certbot_status} != "running" ]]; then
        print_messages "Certbot container is in an unexpected state: ${certbot_status}"
        return 1
    fi
  else
      print_messages "Certbot container is not running."
      break
  fi
    sleep 5
    ((attempt_count++))
done
  if ((attempt_count == max_attempts)); then
    print_messages "Certbot process timed out."
    return 1
  fi
}
