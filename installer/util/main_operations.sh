#!/usr/bin/env bash

set -euo pipefail

#######################################
# Read service names from the JSON file
# Arguments:
#   1
#######################################
read_service_names() {
  local install_profile=$1
  jq -r '.services | keys | .[]' "${install_profile}"
}

#######################################
# Improved setup function using dynamic service names
# Globals:
#   backend_directory
#   build_certbot_image
#   certbot_dir
#   disable_docker_build_caching
#   docker_compose_file
#   exposed_nginx_port
#   frontend_dir
#   project_logs_dir
#   project_root_dir
#   release_branch
# Arguments:
#  None
#######################################
setup() {
  setup_directory_structure "${frontend_dir}" "${backend_directory}" "${certbot_dir}" "${project_logs_dir}"
  initialize_rootless_docker
  ensure_port_is_available "${exposed_nginx_port}" "auto"

  handle_auto_install "${auto_install_flag}" "${use_letsencrypt}" "${install_profile}" "${project_root_dir}"
  print_message "Building server configuration files..."

  generate_backend_dotenv "${backend_dotenv_file}" "${google_maps_api_key}" "${origin_url}" "${use_ssl_flag}"
  generate_frontend_dotenv "${frontend_dotenv_file}" "${use_google_api_key}"
  generate_backend_dockerfile "${backend_dockerfile}" "${backend_submodule_url}" "${node_version}" "${release_branch}" "${express_port}"
  generate_sitemap "${origin_url}" "${sitemap_xml}"
  generate_robots "${robots_file}"
  generate_nginx_mime_types "${nginx_mime_types_file}"

  generate_frontend_dockerfile "${frontend_dockerfile}" "${frontend_submodule_url}" "${node_version}" "${release_branch}" "${use_google_api_key}"

  [[ ${build_certbot_image} == "true" ]] && generate_certbot_dockerfile

  generate_docker_compose "${docker_compose_file}" "${service_to_standard_config_map[@]}"

  generate_nginx_configuration "${backend_scheme}" "${diffie_hellman_parameters_file}" "${dns_resolver}" "${nginx_configuration_file}" "${release_branch}" "${timeout}" "${use_gzip_flag}" "${use_hsts}" "${use_letsencrypt}" "${use_ocsp_stapling}" "${use_self_signed_certs}" "${use_tls_12_flag}" "${use_tls_13_flag}" "${service_to_standard_config_map[@]}"
  build_and_run_docker "${build_certbot_image}" "${docker_compose_file}" "${project_logs_dir}" "${project_root_dir}" "${release_branch}" "${disable_docker_build_caching}"
}

#######################################
# Uninstallation and cleanup functions, now dynamically handling service resources
# Globals:
#   project_root_dir
# Arguments:
#  None
#######################################
uninstall() {
  verify_docker
  print_multiple_messages "Cleaning up..."
  purge

  if [[ -d ${project_root_dir} ]]; then
    local delete_project_dir
    read -r -p "Do you want to delete the project directory ${project_root_dir}? [y/N]: " delete_project_dir
    if [[ ${delete_project_dir} =~ ^[Yy]$ ]]; then
      print_message "Deleting Project directory ${project_root_dir}..."
      rm -rf "${project_root_dir}"
      print_message "Project directory ${project_root_dir} deleted."
    else
      print_message "Project directory ${project_root_dir} not deleted."
    fi
  fi

  print_message "Uninstallation complete."
}

#######################################
# Purge resources for all services in the install profile
# Globals:
#   install_profile
# Arguments:
#  None
#######################################
purge() {
  local service_name
  verify_docker
  print_message "Identifying and purging associated resources..."

  # Dynamically get service names
  local service_names=($(read_service_names "${install_profile}"))

  for service_name in "${service_names[@]}"; do
    purge_resources "${service_name}"
  done
}

#######################################
# Stop and remove containers, images, volumes, and networks for a given service
# Arguments:
#   1
#######################################
purge_resources() {
  local name="$1"

  # Stop all containers, remove images, volumes, and networks for the service
  stop_containers

  # Containers
  print_message "Stopping and removing containers for service ${name}..."
  docker ps -a --format '{{.Names}}' | grep -E "${name}" | xargs -r -I{} docker stop {}
  docker ps -a --format '{{.Names}}' | grep -E "${name}" | xargs -r -I{} docker rm {}

  # Images
  print_message "Removing images for service ${name}..."

  # Specifically handle '<none>:<none>' images if 'name' matches '<none>' or swallow if there are no '<none>:<none>' images
  docker images -a | grep none | awk '{ print $3; }' | xargs -r -I{} docker rmi --force {}

  # Remove images with the service name
  docker images --format '{{.Repository}}:{{.Tag}}' | grep -E "${name}" | xargs -r -I{} docker rmi --force {}

  # Remove images with the service name
  docker images --format '{{.Repository}}:{{.Tag}}' | grep -E "${name}" | xargs -r -I{} docker rmi --force {}

  # Volumes
  print_message "Removing volumes for service ${name}..."
  docker volume ls --format '{{.Name}}' | grep -E "${name}" | xargs -r -I{} docker volume rm --force {}
  print_message "Removing dangling volumes..."
  docker volume ls -qf dangling=true | xargs -r docker volume rm

  # Networks
  print_message "Removing networks for service ${name}..."
  docker network ls --format '{{.Name}}' | grep -E "${name}" | xargs -r -I{} docker network rm --force {}
  print_message "Removing dangling networks..."
  docker network ls -qf dangling=true | xargs -r docker network rm
}

#######################################
# Stop containers using docker-compose
# Globals:
#   docker_compose_file
# Arguments:
#  None
#######################################
stop_containers() {
  verify_docker
  if check_docker_compose "${docker_compose_file}"; then
    print_message "Stopping containers using docker-compose..."
    docker compose -f "${docker_compose_file}" down
  fi
}