#!/bin/bash

bring_down_docker_compose() {
  test_docker_env
  if docker_compose_exists; then
    docker compose -f "$PROJECT_ROOT_DIR/docker-compose.yml" down
  fi
}
