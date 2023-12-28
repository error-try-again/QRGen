#!/usr/bin/env bash

set -euo pipefail

#######################################
# Dumps logs of all containers orchestrated by the Docker Compose file.
# Globals:
#   PROJECT_LOGS_DIR
# Arguments:
#  None
#######################################
function dump_logs() {
  test_docker_env
  mkdir -p "$PROJECT_LOGS_DIR"
  produce_docker_logs > "$PROJECT_LOGS_DIR/service.log" && {
    echo "Docker logs dumped to $PROJECT_LOGS_DIR/service.log"
    cat "$PROJECT_LOGS_DIR/service.log"
  }
}

#######################################
# Check if Docker Compose exists and prints all services defined in the Compose file
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function produce_docker_logs() {
  if docker_compose_exists; then

    # Get a list of services defined in the Compose file
    local services
    local service

    services=$(docker compose -f "$DOCKER_COMPOSE_FILE" config --services)

    # Loop through each service and produce logs
    for service in $services; do
      echo "Logs for service: $service" "@" "$(date)"
      docker compose -f "$DOCKER_COMPOSE_FILE" logs "$service"
      echo "--------------------------------------------"
    done
  else
    echo "Docker Compose not found. Please install Docker Compose."
  fi
}
