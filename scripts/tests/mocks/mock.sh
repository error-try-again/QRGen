#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Setup a mock run environment for a particular service based on the configuration specified
# The function takes three arguments:
#   1 - service: the service for which the mock environment is being setup
#   2 - config: the configuration mode for the mock environment (e.g., letsencrypt, self_signed)
#   3 - file:   let the script run with a specific file (e.g., le.conf, ss.conf)
#######################################
function setup_and_run_mock() {
  local service=$1
  local config=$2
  local file=$3
  print_multi_separated_message "Running ${service} ${config} mocks..."
  reset_dotenv_defaults && setup_common_mock_parameters
  if [[ ${config} == "letsencrypt" ]]; then
    setup_letsencrypt_mock_parameters
  elif [[ ${config} == "self_signed" ]]; then
    setup_self_signed_mock_parameters
  fi
  run_service_mock "${service}" "${config}" "${file}"
}

#######################################
# Run nginx service mock with various configs
# Arguments: None
#######################################
function run_nginx_mocks() {
  setup_and_run_mock "nginx" "letsencrypt" "le.conf"
  setup_and_run_mock "nginx" "self-signed" "ss.conf"
  setup_and_run_mock "nginx" "dev" "dev.conf"
}

#######################################
# Run docker-compose service mock with various configs
# Arguments: None
#######################################
function run_docker_compose_mocks() {
  setup_and_run_mock "docker-compose" "letsencrypt" "le.yml"
  setup_and_run_mock "docker-compose" "self-signed" "ss.yml"
  setup_and_run_mock "docker-compose" "dev" "dev.yml"
}

#######################################
# Run Dockerfile service mock with various configs
# Arguments:  None
#######################################
function run_docker_file_mocks() {
  setup_and_run_mock "dockerfile" "certbot" "certbot.Dockerfile"
  setup_and_run_mock "dockerfile" "frontend" "frontend.Dockerfile"
  setup_and_run_mock "dockerfile" "backend" "backend.Dockerfile"
}

#######################################
# Run mock environment for testing
# Arguments:  None
#######################################
function mock() {
  print_multi_separated_message "Running Mocks..."

  # Setup common configuration parameters
  setup_common_mock_parameters

  # Run the upstream mock server
  mock_upstream_server

  run_nginx_mocks
  run_docker_compose_mocks
  run_docker_file_mocks
  gracefully_terminate_mock_server

  print_multi_separated_message "Mocks complete"
}

#######################################
# Creates a local test for a given microservice, running it in isolation
# The function operates with a defined global variable "test_output_dir", where it stores output files
# Three parameters are expected:
#   1 - service_stack: the microservice stack to be tested
#   2 - service_variant: microservice performance profile
#   3 - config_file_name: the name of the relevant configuration file for the service
#######################################
function run_service_mock() {
  local service_stack=$1
  local service_variant=$2
  local config_file_name=$3
  local operational_log
  local conf_file_path
  local message

  conf_file_path="${test_output_dir}/${service_stack}/${service_variant}/${config_file_name}"
  operational_log="${test_output_dir}/${service_stack}/${service_variant}/ops_log_$(report_timestamp).log"

  mkdir -p "${test_output_dir}/${service_stack}/${service_variant}"

  print_separator
  print_multi_message "Building config - [${service_stack}] - [${service_variant}]"
  generate_configuration_file "${service_stack}" "${service_variant}" "${conf_file_path}" "${operational_log}"
  print_separator
}
