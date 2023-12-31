#!/usr/bin/env bash

set -euo pipefail

#######################################
# Dumps logs for a given service.
# Arguments:
#   1 - Service name
#   2 - Date and time
# Globals:
#   DOCKER_COMPOSE_FILE
#   PROJECT_LOGS_DIR
#######################################
function dump_service_logs() {
  local service="$1"
  local datetime="$2"
  local separator="---------------------------------------"

  print_messages "Dumping logs for service: ${service} at ${datetime}"
  local logs
  logs=$(docker compose -f "${DOCKER_COMPOSE_FILE}" logs "${service}")

  local log_file="${PROJECT_LOGS_DIR}/${service}_${datetime// /_}.log"
  print_messages "${logs}" > "${log_file}"
  print_messages "Logs for ${service} saved to ${log_file}"
  echo "${separator}"
}

#######################################
# Dumps logs of all containers orchestrated by the Docker Compose file.
# Globals:
#   PROJECT_LOGS_DIR
#   DOCKER_COMPOSE_FILE
#######################################
function dump_logs() {
  check_docker_compose || return 1
  mkdir -p "${PROJECT_LOGS_DIR}"

  local datetime
  datetime=$(date "+%Y-%m-%d_%H-%M-%S")

  local services
  services=$(docker compose -f "${DOCKER_COMPOSE_FILE}" config --services)

  local service
  for service in ${services}; do
    dump_service_logs "${service}" "${datetime}"
  done
}
