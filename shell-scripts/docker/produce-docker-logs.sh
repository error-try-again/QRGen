#!/bin/bash

produce_docker_logs() {
  if docker_compose_exists; then
    # Define the path to your Docker Compose file
    local COMPOSE_FILE="$PROJECT_ROOT_DIR/docker-compose.yml"

    # Check if the Compose file exists
    if [ ! -f "$COMPOSE_FILE" ]; then
      echo "Docker Compose file not found: $COMPOSE_FILE"
      return 1
    fi

    # Get a list of services defined in the Compose file
    local SERVICES
    local service

    SERVICES=$(docker compose -f "$COMPOSE_FILE" config --services)

    # Loop through each service and produce logs
    for service in $SERVICES; do
      echo "Logs for service: $service"
      docker compose -f "$COMPOSE_FILE" logs "$service"
      echo "--------------------------------------------"
    done
  else
    echo "Docker Compose not found. Please install Docker Compose."
  fi
}
