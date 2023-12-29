#!/usr/bin/env bash
# bashsupport disable=BP5006

#######################################
# Mocks the development nginx configuration (no ssl/letsencrypt)
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_nginx_dev_mock() {
  echo "---------------------------------------"
  echo "Simulating NGINX configuration for http only..."

  setup_dev_mock_parameters

  NGINX_CONF_FILE="${test_output_dir}/nginx-dev.conf"

  configure_nginx_config 2>&1 | tee "${test_output_dir}/nginx_dev_output.log"

  # Check for errors in the output and log them
  local nginx_output
  nginx_output=$(< "${test_output_dir}/nginx_dev_output.log")

  log_mock_error "${nginx_output}"

  validate_service_config "${NGINX_CONF_FILE}" "nginx"
}
