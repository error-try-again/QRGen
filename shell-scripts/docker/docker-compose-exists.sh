#!/bin/bash

docker_compose_exists() {
  [[ -f "$PROJECT_ROOT_DIR/docker-compose.yml" ]]
}
