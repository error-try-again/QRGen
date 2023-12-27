#!/usr/bin/env bash

set -euo pipefail

#######################################
# Dumps logs of all containers orchestrated by the Docker Compose file.
# Globals:
#   PROJECT_LOGS_DIR
# Arguments:
#  None
#######################################
dump_logs() {
  test_docker_env
  mkdir -p "$PROJECT_LOGS_DIR"
  produce_docker_logs > "$PROJECT_LOGS_DIR/service.log" && {
    echo "Docker logs dumped to $PROJECT_LOGS_DIR/service.log"
    cat "$PROJECT_LOGS_DIR/service.log"
  }
}
