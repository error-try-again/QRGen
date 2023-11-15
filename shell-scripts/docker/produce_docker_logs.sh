#!/bin/bash

#######################################
# description
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
produce_docker_logs() {
  if docker_compose_exists; then
    # Define the path to your Docker Compose file
    local compose_file="$PROJECT_ROOT_DIR/docker-compose.yml"

    # Check if the Compose file exists
    if [ ! -f "$compose_file" ]; then
      echo "Docker Compose file not found: $compose_file"
      return 1
    fi

    # Get a list of services defined in the Compose file
    local services
    local service

    services=$(docker compose -f "$compose_file" config --services)

    # Loop through each service and produce logs
    for service in $services; do
      echo "Logs for service: $service" "@" "$(date)"
      docker compose -f "$compose_file" logs "$service"
      echo "--------------------------------------------"
    done
  else
    echo "Docker Compose not found. Please install Docker Compose."
  fi
}
