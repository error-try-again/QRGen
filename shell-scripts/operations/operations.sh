#!/bin/bash

# --- User Actions --- #

# Dumps logs of all containers orchestrated by the Docker Compose file.
dump_logs() {
  test_docker_env
  produce_docker_logs >"$PROJECT_LOGS_DIR" && {
    echo "Docker logs dumped to $PROJECT_LOGS_DIR"
    cat "$PROJECT_LOGS_DIR"
  }
}

# Cleans current Docker Compose setup, arranges directories, and reinitiates Docker services.
reload_project() {
  echo "Reloading the project..."
  test_docker_env
  setup_project_directories
  bring_down_docker_compose
  generate_server_files
  configure_nginx
  build_and_run_docker
  dump_logs
}

# Shuts down any running Docker containers associated with the project and deletes the entire project directory.
cleanup() {
  test_docker_env
  echo "Cleaning up..."

  bring_down_docker_compose

  declare -A directories=(
    ["Project"]=$PROJECT_ROOT_DIR
    ["Frontend"]=$FRONTEND_DIR
    ["Backend"]=$BACKEND_DIR
  )

  local dir_name
  local dir_path

  for dir_name in "${!directories[@]}"; do
    dir_path="${directories[$dir_name]}"
    if [[ -d "$dir_path" ]]; then
      rm -rf "$dir_path"
      echo "$dir_name directory $dir_path deleted."
    fi
  done

  echo "Cleanup complete."
}

update_project() {
  git stash
  git pull
}

purge_builds() {
  test_docker_env
  local containers
  containers=$(docker ps -a -q)
  echo "Stopping all containers..."
  if [ -n "$containers" ]; then
    docker stop $containers
  else
    echo "No containers to stop."
  fi
  echo "Purging Docker builds..."
  docker system prune -a
}

quit() {
  echo "Exiting..."
  exit 0
}

# ---- Build and Run Docker ---- #

build_and_run_docker() {
  echo "Building and running Docker setup..."

  cd "$PROJECT_ROOT_DIR" || {
    echo "Failed to change directory to $PROJECT_ROOT_DIR"
    exit 1
  }

  initialize_cert_watcher || {
    echo "Failed to initialize cert watcher"
    exit 1
  }

  # Build Docker image
  docker compose build || {
    echo "Failed to build Docker image using Docker Compose"
    exit 1
  }

  docker compose up -d || {
    echo "Failed to run Docker Compose"
    exit 1
  }

  docker compose ps
  dump_logs
}
