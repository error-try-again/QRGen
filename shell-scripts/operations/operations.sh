#!/usr/bin/env bash

#######################################
# Setup project directories and configurations.
# Globals:
#   NGINX_PORT
# Arguments:
#  None
#######################################
setup() {
  setup_project_directories
  setup_docker_rootless
  ensure_port_available "$NGINX_PORT"
  prompt_for_install_mode
  disable_docker_build_caching_prompt
  prompt_for_google_api_key
  prompt_for_domain_and_letsencrypt
  generate_server_files
  configure_nginx
  build_and_run_docker
}

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

#######################################
# Shuts down any running Docker containers associated with the project and deletes the entire project directory.
# Arguments:
#  None
#######################################
uninstall() {
  test_docker_env
  echo "Cleaning up..."
  purge_builds

  # Directly delete the project root directory
  if [[ -d $PROJECT_ROOT_DIR ]]; then
    echo "Deleting Project directory $PROJECT_ROOT_DIR..."
    rm -rf "$PROJECT_ROOT_DIR"
    echo "Project directory $PROJECT_ROOT_DIR deleted."
  fi

  echo "Uninstallation complete."
}

#######################################
# Moves user changes to stash and pulls latest changes from the remote repository.
# Arguments:
#  None
#######################################
update_project() {
  git stash
  git pull
}

#######################################
# Stops, removes Docker containers, images, volumes, and networks starting with 'qrgen'.
# Globals:
#   None
# Arguments:
#  None
#######################################
purge_builds() {
  test_docker_env

  echo "Identifying and purging Docker resources associated with 'qrgen'..."

  # Stop and remove containers
  if docker ps -a --format '{{.Names}}' | grep -q '^qrgen'; then
    echo "Stopping and removing 'qrgen' containers..."
    docker ps -a --format '{{.Names}}' | grep '^qrgen' | xargs -r docker stop
    docker ps -a --format '{{.Names}}' | grep '^qrgen' | xargs -r docker rm
  else
    echo "No 'qrgen' containers found."
  fi

  # Remove images
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^qrgen'; then
    echo "Removing 'qrgen' images..."
    docker images --format '{{.Repository}}:{{.Tag}}' | grep '^qrgen' | xargs -r docker rmi --force
  else
    echo "No 'qrgen' images found."
  fi

  # Remove volumes
  if docker volume ls --format '{{.Name}}' | grep -q '^qrgen'; then
    echo "Removing 'qrgen' volumes..."
    docker volume ls --format '{{.Name}}' | grep '^qrgen' | xargs -r docker volume rm --force
  else
    echo "No 'qrgen' volumes found."
  fi

  # Remove networks
  if docker network ls --format '{{.Name}}' | grep -q '^qrgen'; then
    echo "Removing 'qrgen' networks..."
    docker network ls --format '{{.Name}}' | grep '^qrgen' | xargs -r docker network rm --force
  else
    echo "No 'qrgen' networks found."
  fi
}

#######################################
# Exits the script cleanly.
# Arguments:
#  None
#######################################
quit() {
  echo "Quitting..."
  exit 0
}

#######################################
# Checks whether certs are required, if so, generates them.
# Initializes cert file watcher to watch for changes to the certs.
# Globals:
#   USE_LETS_ENCRYPT
# Arguments:
#  None
#######################################
handle_certs() {
  # Handle Let's Encrypt configuration
  if [[ $USE_LETS_ENCRYPT == "yes" ]] || [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then
    # Generate self-signed certificates if they don't exist
    generate_self_signed_certificates
  fi
}

#######################################
# Function to remove containers that conflict with Docker Compose services
# Globals:
#   PWD
# Arguments:
#  None
#######################################
remove_conflicting_containers() {
  # Extract service names from docker-compose.yml
  local service_names
  service_names=$(docker compose config --services)

  # Loop through each service name to check if corresponding container exists
  for service in $service_names; do
    # Generate the probable container name based on the folder name and service name
    # e.g. In this instance, since the project name is "QRGen" and the service
    # name is "backend", the probable container name would be "QRGen_backend_1"
    local probable_container_name="${PWD##*/}_${service}_1"

    # Check if a container with the generated name exists
    if docker ps -a --format '{{.Names}}' | grep -qw "$probable_container_name"; then
      echo "Removing existing container that may conflict: $probable_container_name"
      docker rm -f "$probable_container_name"
    else
      echo "No conflict for $probable_container_name"
    fi
  done
}

#######################################
# Function to handle ambiguous Docker networks
# Arguments:
#  None
#######################################
handle_ambiguous_networks() {
  echo "Searching for ambiguous Docker networks..."
  local networks_ids
  local network_id

  # Get all custom networks (excluding default ones)
  networks_ids=$(docker network ls --filter name=qrgen --format '{{.ID}}')

  # Loop over each network ID
  for network_id in $networks_ids; do
    echo "Inspecting network $network_id for connected containers..."
    local container_ids
    local container_id
    container_ids=$(docker network inspect "$network_id" --format '{{range .Containers}}{{.Name}} {{end}}')

    # Loop over each container ID connected to the network and disconnect it
    for container_id in $container_ids; do
      echo "Disconnecting container $container_id from network $network_id..."
      docker network disconnect -f "$network_id" "$container_id" || {
        echo "Failed to disconnect container $container_id from network $network_id"
      }
    done

    # Remove the network
    echo "Removing network $network_id..."
    docker network rm "$network_id" || {
      echo "Failed to remove network $network_id"
    }
  done
}

#######################################
# Modifies the docker-compose.yml file to remove specified flags
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#   1 - Flag to remove
# Returns:
#   Path to the temporary modified file
#######################################
modify_docker_compose() {
  local flag_to_remove=$1
  local temp_file
  temp_file="$(mktemp)"

  # Perform the modification
  sed "/certbot:/,/command:/s/$flag_to_remove//" "$DOCKER_COMPOSE_FILE" > "$temp_file"

  # Output only the path to the temporary file
  echo "$temp_file"
}

#######################################
# Checks if the specified flag is removed from the file
# Globals:
#   None
# Arguments:
#   1 - File to check
#   2 - Flag to check for
#######################################
check_flag_removal() {
  local file=$1
  local flag=$2

  if grep --quiet -- "$flag" "$file"; then
    echo "$flag removal failed."
    rm "$file"
    exit 1
  else
    echo "$flag removed successfully."
  fi
}

#######################################
# Backs up the original file and replaces it with the modified version
# Globals:
#   None
# Arguments:
#   1 - Original file
#   2 - Modified file
#######################################
backup_and_replace_file() {
  local original_file=$1
  local modified_file=$2

  # Backup the original file
  cp -rf "$original_file" "${original_file}.bak"

  # Replace the original file with the modified version
  mv "$modified_file" "$original_file"
  echo "File updated and original version backed up."
}

#######################################
# Strips the dry run certbot command flag
# Additionally, backing up and replacing the original docker-compose.yml file
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
remove_dry_run_flag() {
  local temp_file
  echo "Removing --dry-run flag from docker-compose.yml..."
  temp_file=$(modify_docker_compose '--dry-run')
  check_flag_removal "$temp_file" '--dry-run'
  backup_and_replace_file "${DOCKER_COMPOSE_FILE}" "$temp_file"
}

#######################################
# Strips the staging certbot command flag
# Additionally, backing up and replacing the original docker-compose.yml file
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
remove_staging_flag() {
  local temp_file
  echo "Removing --staging flag from docker-compose.yml..."
  temp_file=$(modify_docker_compose '--staging')
  check_flag_removal "$temp_file" '--staging'
  backup_and_replace_file "${DOCKER_COMPOSE_FILE}" "$temp_file"
}

#######################################
# Builds and runs the backend service
# Checks to see if caching is disabled, and builds accordingly
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
run_backend_service() {
  if [[ $DISABLE_DOCKER_CACHING == "yes" ]]; then
    echo "Building and running Backend service without caching..."
    if ! docker compose build --no-cache --progress=plain backend; then
      echo "Failed to build Backend service."
      exit 1
    fi
    docker compose up -d backend
  else
    echo "Building and running Backend service..."
    if ! docker compose build --progress=plain backend; then
      echo "Failed to build Backend service."
      exit 1
    fi
    docker compose up -d backend
  fi
}

#######################################
# Builds and runs the frontend service
# Checks to see if caching is disabled, and builds accordingly
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
run_frontend_service() {
    if [[ $DISABLE_DOCKER_CACHING == "yes" ]]; then
     echo "Building and running Frontend service without caching..."
      if ! docker compose build --no-cache --progress=plain frontend; then
          echo "Failed to build Frontend service."
          exit 1
    fi
      docker compose up -d frontend
  else
      echo "Building and running Frontend service..."
      if ! docker compose build --progress=plain frontend; then
          echo "Failed to build Frontend service."
          exit 1
    fi
      docker compose up -d frontend
  fi
}

#######################################
# Runs the Certbot service, checks for dry run success, strips the dry run flag,
# and runs the Certbot service again. Finally, restarts the backend and frontend services.
# When running in production, the staging flag is also removed.
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
run_certbot_service() {
  echo "Running Certbot service..."
  build_certbot_service || exit 1
  run_certbot_dry_run || exit 1
  rebuild_and_rerun_certbot || exit 1
  wait_for_certbot_completion || exit 1
  check_certbot_success || exit 1
  echo "Certbot process completed successfully."
}

#######################################
# Builds the Certbot service
# Checks to see if caching is disabled, and builds accordingly
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
build_certbot_service() {
  if [[ $DISABLE_DOCKER_CACHING == "yes" ]]; then
    echo "Building Certbot service without caching..."
    if ! docker compose build --no-cache --progress=plain certbot; then
      echo "Failed to build Certbot service."
      return 1
    fi
  fi
}

#######################################
# Determines whether to use staging or production Let's Encrypt servers
# Depends on whether the dry run was successful
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
run_certbot_dry_run() {
  local certbot_output
  if ! certbot_output=$(docker compose run --rm certbot 2>&1); then
    echo "Certbot dry-run command failed."
    echo "Output: $certbot_output"
    return 1
  fi
  if [[ $certbot_output == *'The dry run was successful.'* ]]; then
    echo "Certbot dry run successful."
    remove_dry_run_flag
    handle_staging_flags
  else
    echo "Certbot dry run failed."
    return 1
  fi
}

#######################################
# Provides removal of the staging flag when running in production mode
# Globals:
#   USE_PRODUCTION_SSL
# Arguments:
#  None
#######################################
handle_staging_flags() {
  if [[ ${USE_PRODUCTION_SSL:-no} == "yes" ]]; then
    echo "Certbot is running in production mode."
    echo "Removing --staging flag from docker-compose.yml..."
    remove_staging_flag
  fi
}

#######################################
# Rebuilds certbot with caching to perform the actual certificate request or renewal.
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
rebuild_and_rerun_certbot() {
  echo "Rebuilding and rerunning Certbot without dry-run..."
  if ! docker compose build certbot || ! docker compose up -d certbot; then
    echo "Failed to rebuild or run Certbot service."
    return 1
  fi
}

#######################################
# Iteratively waits for the certbot docker container to have finished
# Then checks the logs for success or failure and returns accordingly
# Arguments:
#  None
# Returns:
#   0 ...
#   1 ...
#######################################
wait_for_certbot_completion() {
  local attempt_count=0
  local max_attempts=12
  while ((attempt_count < max_attempts)); do

    local certbot_container_id
    local certbot_status

    certbot_container_id=$(docker compose ps -q certbot)

    if [[ -n $certbot_container_id ]]; then

      certbot_status=$(docker inspect -f '{{.State.Status}}' "$certbot_container_id")
      echo "Attempt $attempt_count"
      echo "Certbot container status: $certbot_status"

      if [[ $certbot_status == "exited" ]]; then
        return 0
      elif [[ $certbot_status != "running" ]]; then
        echo "Certbot container is in an unexpected state: $certbot_status"
        return 1
      fi
    else
      echo "Certbot container is not running."
      break
    fi
    sleep 5
    ((attempt_count++))
  done
  if ((attempt_count == max_attempts)); then
    echo "Certbot process timed out."
    return 1
  fi
}

#######################################
# Checks the certbot logs for key strings and restarts services accordingly
# This ensures that services go live after a certificate renewal
# Arguments:
#  None
# Returns:
#   0 ...
#   1 ...
#######################################
check_certbot_success() {
  local certbot_logs
  certbot_logs=$(docker compose logs certbot)
  echo "Certbot logs: $certbot_logs"

  # Check for specific messages indicating certificate renewal success or failure
  if [[ $certbot_logs == *'Certificate not yet due for renewal'* ]]; then
    echo "Certificate is not yet due for renewal."
    return 0
  elif [[ $certbot_logs == *'Renewing an existing certificate'* ]]; then
    echo "Certificate renewal successful."
    restart_services
    return 0
  elif [[ $certbot_logs == *'Successfully received certificate.'* ]]; then
    echo "Certificate creation successful."
    restart_services
    return 0
  else
    echo "Certbot process failed."
    return 1
  fi
}

#######################################
# Restarts the frontend and backend services depending on the release branch
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
restart_services() {
  echo "Restarting backend and frontend services..."
  if [[ $RELEASE_BRANCH = "full-release" ]]; then
    if ! docker compose restart backend || ! docker compose restart frontend; then
      echo "Failed to restart services."
      return 1
    fi
  else
    if ! docker compose restart frontend; then
      echo "Failed to restart services."
      return 1
    fi
  fi
}

#######################################
# Manages conflicting Docker networks and containers
# Arguments:
#  None
#######################################
pre_flight() {
  # Remove containers that would conflict with `docker-compose up`
  remove_conflicting_containers || {
    echo "Failed to remove conflicting containers"
    exit 1
  }

  handle_ambiguous_networks || {
    echo "Failed to handle ambiguous networks"
    exit 1
  }
}

#######################################
# Performs common build operations
# Globals:
#   PROJECT_ROOT_DIR
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
common_build_operations() {
      cd "$PROJECT_ROOT_DIR" || {
      echo "Failed to change directory to $PROJECT_ROOT_DIR"
      exit 1
  }

    pre_flight || {
      echo "Failed pre-flight checks"
      exit 1
  }

    # If Docker Compose is running, bring down the services
    # Ensure that old services are brought down before proceeding
    if docker compose ps &> /dev/null; then
      echo "Bringing down existing Docker Compose services..."
      docker compose down || {
        echo "Failed to bring down existing Docker Compose services"
        exit 1
    }
  fi

    handle_certs || {
      echo "Failed to handle certs"
      exit 1
  }

    # Run each service separately - must be active for certbot to work
    if [[ $RELEASE_BRANCH = "full-release" ]]; then
      run_backend_service
      run_frontend_service
  else
      run_frontend_service
  fi
}

#######################################
# ---- Build and Run Docker ---- #
# Globals:
#   PROJECT_ROOT_DIR
#   USE_AUTO_RENEW_SSL
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
build_and_run_docker() {
    echo "Building and running Docker services..."

    common_build_operations || {
      echo "Failed common build operations"
      exit 1
  }

    if [[ $USE_AUTO_RENEW_SSL == "yes" ]]; then
      run_certbot_service
      echo "Using auto-renewal for SSL certificates."
      generate_certbot_renewal_job
  fi

    # Dump logs or any other post-run operations
    dump_logs || {
      echo "Failed to dump logs"
      exit 1
  }
}
