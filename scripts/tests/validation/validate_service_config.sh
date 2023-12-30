#!/usr/bin/env bash
# bashsupport disable=BP5006
set -euo pipefail

#######################################
# Tries to execute a command and outputs an error message
# with the given "message" if the command fails.
# Arguments:
#  message: The error message to be displayed in case the command fails.
#  command: The command to execute.
#######################################
function assert_or_error() {
  local message
  local command
  message="$1"
  shift
  command="$*"
  ${command} || {
    echo "Error: ${message}"
    exit 1
  }
}

#######################################
# Validates a configuration file using a given command
# and logs the validation output.
# Arguments:
#  conf_file_path: The path of the configuration file to validate.
#  command: The command used to validate the configuration file.
#######################################
function validate_file() {
  local conf_file_path
  local command
  local directory
  local log_file

  conf_file_path="$1"
  command="$2"
  directory=$(dirname "${conf_file_path}")
  log_file="${directory}/validation_log_$(report_timestamp).log"

  print_multi_message "Validation log can be found at: ${log_file}" "Running command: ${command}"
  if ! ${command} &> "${log_file}"; then
    print_multi_message "Validation failed for file ${conf_file_path}" "Complete validation log can be found at ${log_file}"
  else
    print_multi_message "Validation succeeded for file ${conf_file_path}" "Complete validation log can be found at ${log_file}"
  fi
}

#######################################
# validates an Nginx configuration file.
# Arguments:
#  conf_file_path: The path of the Nginx configuration file to validate.
#######################################
function validate_nginx_file() {
  local conf_file_path
  conf_file_path="$1"
  assert_or_error "Nginx has no port: ${conf_file_path}" assert_nginx_has_port "${conf_file_path}"
  validate_file "${conf_file_path}" "nginx -t -c ${conf_file_path}"
}

#######################################
# Validates a Docker Compose file.
# Arguments:
#  conf_file_path: The path of the Docker Compose file to validate.
#######################################
function validate_docker_compose_file() {
  local conf_file_path
  conf_file_path="$1"
  assert_or_error "Compose has no port: ${conf_file_path}" assert_compose_has_port "${conf_file_path}"
  validate_file "${conf_file_path}" "docker compose -f ${conf_file_path} config"
}

#######################################
# Provides function to generate a configuration file for a given service variant.
# Arguments:
#   1
#   2
#   3
#   4
#######################################
function generate_and_log_config() {
  local conf_file_path=$1
  local operational_log=$2
  local service_variant=$3
  local generate_func=$4

  if ${generate_func} &> "${operational_log}"; then
    print_multi_message "[${service_variant}] configuration generated and saved to: ${conf_file_path}" "Complete operational log can be found at: ${operational_log}"
  fi

  # Append the timestamps to the operations log file
  append_timestamps_to_log "${operational_log}"
}

#######################################
# Generates a configuration file for a given service variant.
# Globals:
#   BACKEND_DOCKERFILE
#   CERTBOT_DOCKERFILE
#   DOCKER_COMPOSE_FILE
#   FRONTEND_DOCKERFILE
#   NGINX_CONF_FILE
# Arguments:
#  1 - service_stack: The type of the service (either 'nginx' or 'docker-compose')
#  2 - service_variant: The variant of the service.
#  3 - conf_file_path: The path where the configuration file will be saved.
#  4 - operational_log: The log file where the output will be logged.
# Returns:
#   1 ...
#######################################
function generate_configuration_file() {
  local service_stack=$1
  local service_variant=$2
  local conf_file_path=$3
  local operational_log=$4

  assert_or_error "Expected four arguments, but got: $#." [ "$#" -eq 4 ]
  generate_file_paths "${conf_file_path}"

  case ${service_stack} in
    nginx)
      NGINX_CONF_FILE="${conf_file_path}"
      generate_and_log_config "${conf_file_path}" "${operational_log}" "${service_variant}" generate_nginx_config
      validate_nginx_file "${conf_file_path}"
      ;;
    docker-compose)
      DOCKER_COMPOSE_FILE="${conf_file_path}"
      generate_and_log_config "${conf_file_path}" "${operational_log}" "${service_variant}" generate_docker_compose
      validate_docker_compose_file "${conf_file_path}"
      ;;
    dockerfile)
      handle_dockerfile_variants "${service_variant}" "${conf_file_path}" "${operational_log}"
      ;;
    *)
      print_multi_message "Failed to validate configuration file. Unknown service stack: ${service_stack}" "Complete operational log can be found at: ${operational_log}"
      return 1
      ;;
  esac
}

#######################################
# Handle the potential dockerfile variants.
# Globals:
#   BACKEND_DOCKERFILE
#   CERTBOT_DOCKERFILE
#   FRONTEND_DOCKERFILE
# Arguments:
#   1
#   2
#   3
#######################################
function handle_dockerfile_variants() {
  local service_variant=$1
  local conf_file_path=$2
  local operational_log=$3

  case ${service_variant} in
    frontend)
      FRONTEND_DOCKERFILE="${conf_file_path}"
      generate_and_log_config "${conf_file_path}" "${operational_log}" "${service_variant}" generate_frontend_dockerfile
      ;;
    backend)
      BACKEND_DOCKERFILE="${conf_file_path}"
      generate_and_log_config "${conf_file_path}" "${operational_log}" "${service_variant}" generate_backend_dockerfile
      ;;
    certbot)
      CERTBOT_DOCKERFILE="${conf_file_path}"
      generate_and_log_config "${conf_file_path}" "${operational_log}" "${service_variant}" generate_certbot_dockerfile
      ;;
    *)
      print_message "Failed to validate configuration file. Unknown service variant: ${service_variant}"
      ;;
  esac
}
