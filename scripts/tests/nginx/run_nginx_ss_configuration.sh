#!/usr/bin/env bash
# bashsupport disable=BP5006

#######################################
# Mocks the self signed certificate generation nginx configuration
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_nginx_ss_mock() {
  echo "---------------------------------------"
  echo "Simulating NGINX configuration for self-signed certificates..."

  setup_self_signed_mock_parameters

  NGINX_CONF_FILE="${test_output_dir}/nginx-ss.conf"

  generate_file_paths "${NGINX_CONF_FILE}"

  configure_nginx_config 2>&1 | tee "${test_output_dir}/nginx_ss_output.log"

  # Check for errors in the output and log them
  local nginx_output
  nginx_output=$(<"${test_output_dir}/nginx_ss_output.log")

  log_mock_error "${nginx_output}"

  validate_service_config "${NGINX_CONF_FILE}" "nginx"
}
