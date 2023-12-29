#!/usr/bin/env bash
# bashsupport disable=BP5006

#######################################
# Mocks the lets encrypt nginx configuration (faux certbot configuration)
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_nginx_le_mock() {
  echo "---------------------------------------"
  echo "Simulating NGINX configuration for Let's Encrypt..."

  setup_letsencrypt_mock_parameters

  NGINX_CONF_FILE="${test_output_dir}/nginx-le.conf"
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker-compose-le.yml"

  configure_nginx_config 2>&1 | tee "${test_output_dir}/nginx_le_output.log"

  # Check for errors in the output and log them
  local nginx_output
  nginx_output=$(<"${test_output_dir}/nginx_le_output.log")

  log_mock_error "${nginx_output}"

  validate_service_config "${NGINX_CONF_FILE}" "nginx"
}
