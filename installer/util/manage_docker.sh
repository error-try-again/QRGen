#!/usr/bin/env bash

#######################################
# Ensures that no conflicting containers or networks exist and removes them
# before starting services
# Arguments:
#  None
#######################################
pre_flight() {
  remove_conflicting_containers
  handle_ambiguous_networks
}

#######################################
#
# Globals:
#   service_to_standard_config_map
# Arguments:
#   1
#   2
#   3
#   4
#   5
#   6
#######################################
build_and_run_docker() {
  local build_certbot_image="$1"
  local docker_compose_file="$2"
  local project_logs_dir="$3"
  local project_root_dir="$4"
  local release_branch="$5"
  local disable_docker_build_caching="$6"

  # Change to project root directory
  cd "${project_root_dir}" || exit 1

  # Run pre-flight procedures
  pre_flight

  # Handle certificates
  handle_certs

  # Building and running docker services with or without cache based on flag
  local service_name
  for service_name in "${!service_to_standard_config_map[@]}"; do
    local cache_option=""

    if [[ ${disable_docker_build_caching} == "true"   ]]; then
      cache_option="--no-cache"
    fi

    # Parse the service name and build the service
    local name
    name=$(echo "${service_name}" | tr '[:upper:]' '[:lower:]')
    docker compose build ${cache_option} "${name}" && docker compose up -d "${name}"

    if [[ ${build_certbot_image} == "true" ]]; then
      docker compose build --no-cache certbot && docker compose up -d certbot
    fi
  done

  # Dump logs
  dump_compose_logs "${docker_compose_file}" "${project_logs_dir}"
}

#######################################
# List and inspect the networks and containers and disconnect and remove them if they are ambiguous
# Globals:
#   service_to_standard_config_map
# Arguments:
#  None
#######################################
handle_ambiguous_networks() {
  print_message "Handling ambiguous networks..."
  local network_name
  for network_name in $(docker network ls --format '{{.Name}}'); do
    if [[ ${network_name} =~ ^(${!service_to_standard_config_map[*]}|default)$   ]]; then
      local containers_in_network
      containers_in_network=$(docker network inspect "${network_name}" --format '{{range .Containers}}{{.Name}} {{end}}')
      local container
      for container in ${containers_in_network}; do
        docker network disconnect -f "${network_name}" "${container}"
      done
      docker network rm "${network_name}" || exit 1
    fi
  done
}

#######################################
#
# Globals:
#   PWD
# Arguments:
#  None
#######################################
remove_conflicting_containers() {
  print_message "Removing conflicting containers..."
  local service
  for service in $(docker compose config --services); do
    local probable_container_name="${service}"
    if docker ps -a --format '{{.Names}}' | grep -qw "${probable_container_name}"; then
      docker rm -f "${probable_container_name}"
    fi
  done
}

#######################################
#
# Globals:
#   service_to_standard_config_map
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
restart_services() {
  print_message "Restarting services..."
  # Restart services dynamically based on unique service names
  local service
  for service in "${!service_to_standard_config_map[@]}"; do
    docker compose restart "${service}" || {
      echo "Failed to restart service: ${service}"
      return 1
    }
  done
}