#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Create a temporary Mock Upstream Server to test NGINX configuration
# Uses netcat to listen on port 12345 and echo "Mock Server" to the client
#######################################
function mock_upstream_server() {
    # Start a dummy server in the background and capture its PID
    nc -lk -p 12345 &
    MOCK_PID=$!
    echo "Started mock server with PID: $MOCK_PID"

    # Wait a little to ensure the server starts
    sleep 1

    # Check if the server started successfully
    if ! kill -0 $MOCK_PID 2> /dev/null; then
        echo "Failed to start mock server."
        exit 1
  fi
}

declare -A error_messages=(
  ["missing_port"]="Missing defined port"
  ["invalid_configuration"]="Invalid configuration detected"
)

#######################################
# Log errors to a file
# Arguments:
#   $1 - Message or output to log
#######################################
function log_error() {
  local message=$1
  local error_log="${test_output_dir}/error.log"

  # Define common error signatures you want to catch
  local common_errors=("Error" "Failed" "Cannot" "Denied" "Unbound" "Timeout" "Refused" "Invalid" "Bad" "Unknown" "Not Found" "Not Available" "Not Allowed")

  local error
  for error in "${common_errors[@]}"; do
    if [[ $message == *$error* ]]; then
      echo "$(date +%Y-%m-%d\ %H:%M:%S) - ERROR: $message" >> "$error_log"
    fi
  done
}

#######################################
# Validate NGINX configuration file
# Arguments:
#   $1 - Configuration file path
#######################################
function validate_nginx_config() {
    local file=$1

    # Validate the configuration syntax
    nginx -t -c "$file" 2>&1 | tee "${test_output_dir}/validation_${file##*/}.log"

    # Specific checks for NGINX configuration
    assert_nginx_has_port "$file"
}

#######################################
# Validate Docker Compose configuration file
# Arguments:
#   $1 - Configuration file path
#######################################
function validate_docker_compose_config() {
    local file=$1

    # Validate the configuration
    docker compose -f "$file" config 2>&1 | tee "${test_output_dir}/validation_${file##*/}.log"

    # Specific checks for Docker Compose configuration
    assert_compose_has_port "$file"
}

#######################################
# Check Configuration Files for Correctness
# Arguments:
#   None
#######################################
function check_configurations() {
  echo "Checking configuration files for correctness..."
  validate_configuration_file "${NGINX_CONF_FILE}"
  validate_configuration_file "${DOCKER_COMPOSE_FILE}"
}

#######################################
# Validate Configuration Files
# Arguments:
#   $1 - Configuration file path
#######################################
function validate_configuration_file() {
  local file=$1
  # Validation command depends on the type of file
  # For NGINX config, use nginx -t
  # For Docker Compose config, use docker-compose -f config.yml config
  if [[ $file == *".conf" ]]; then
    nginx -t -c "$file" 2>&1 | tee "${test_output_dir}/validation_${file##*/}.log"
  elif [[ $file == *"docker_compose"*".yml" ]]; then
    docker compose -f "$file" config 2>&1 | tee "${test_output_dir}/validation_${file##*/}.log"
  fi
  local validation_output
  validation_output=$(< "${test_output_dir}/validation_${file##*/}.log")
  log_error "$validation_output"
}

#######################################
# Run a series of configuration mocks (manually test the configuration scripts)
# Globals:
#   PROJECT_ROOT_DIR
#   test_output_dir
# Arguments:
#  None
#######################################
function run_mocks() {

  echo "Running mocks..."

  mock_upstream_server

  test_output_dir="${PROJECT_ROOT_DIR}/test_output"
  mkdir -p "${test_output_dir}"

  # Ensure NGINX can write to a custom log directory or file
  mkdir -p "${test_output_dir}/logs"
  touch "${test_output_dir}/logs/error.log"
  touch "${test_output_dir}/logs/access.log"

  # Set up a directory for the custom PID file
  mkdir -p "${test_output_dir}/run"
  touch "${test_output_dir}/run/nginx.pid"

  run_nginx_ss_configuration
  run_nginx_le_configuration
  run_nginx_dev_configuration
  run_compose_le_configuration
  run_compose_ss_configuration
  run_compose_dev_configuration
  run_backend_container_configuration
  run_frontend_container_configuration
  run_certbot_container_configuration

  # Run the configuration checks
  check_configurations

  # Kill the mock upstream server
  if kill -0 $MOCK_PID 2> /dev/null; then
      echo "Terminating mock server with PID $MOCK_PID"
      kill $MOCK_PID
  else
      echo "Mock server process $MOCK_PID not found"
  fi
  echo "Mocks complete."
}

#######################################
# Assert that NGINX config has defined port(s)
# Arguments:
#   $1 - NGINX configuration file
#######################################
function assert_nginx_has_port() {
    local file=$1

    # Implement a check for port definition in NGINX config
    if ! grep -qE 'listen[[:space:]]+[0-9]+' "$file"; then
        log_error "missing_port"
  fi
}

#######################################
# Assert that Docker Compose config has defined port(s)
# Arguments:
#   $1 - Docker Compose configuration file
#######################################
function assert_compose_has_port() {
    local file=$1

    # Implement a check for port definition in Docker Compose config
    if ! grep -q 'ports:' "$file"; then
        log_error "missing_port"
  fi
}

#######################################
# Mocks the self signed certificate generation nginx configuration
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_nginx_ss_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_ss.conf"
  setup_common_configuration_parameters
  setup_self_signed_configuration_parameters
  configure_nginx_config 2>&1 | tee "${test_output_dir}/nginx_ss_output.log"

  # Check for errors in the output and log them
  local nginx_output
  nginx_output=$(< "${test_output_dir}/nginx_ss_output.log")
  log_error "$nginx_output"
}

#######################################
# Mocks the lets encrypt nginx configuration (faux certbot configuration)
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_nginx_le_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_le.conf"
  setup_common_configuration_parameters
  setup_letsencrypt_configuration_parameters
  configure_nginx_config 2>&1 | tee "${test_output_dir}/nginx_le_output.log"

  # Check for errors in the output and log them
  local nginx_output
  nginx_output=$(< "${test_output_dir}/nginx_le_output.log")
  log_error "$nginx_output"
}

#######################################
# Mocks the development nginx configuration (no ssl/letsencrypt)
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_nginx_dev_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_dev.conf"
  setup_common_configuration_parameters
  setup_dev_configuration_parameters
  configure_nginx_config 2>&1 | tee "${test_output_dir}/nginx_dev_output.log"

  # Check for errors in the output and log them
  local nginx_output
  nginx_output=$(< "${test_output_dir}/nginx_dev_output.log")
  log_error "$nginx_output"
}

#######################################
# Mocks the docker compose lets encrypt configuration (faux certbot configuration)
# Globals:
#   DOCKER_COMPOSE_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_compose_le_configuration() {
  echo "Simulating Docker Compose configuration with Let's Encrypt..."
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-le.yml"
  setup_common_configuration_parameters
  setup_letsencrypt_configuration_parameters
  configure_docker_compose 2>&1 | tee "${test_output_dir}/compose_le_output.log"

  # Check for errors in the output and log them
  local compose_output
  compose_output=$(< "${test_output_dir}/compose_le_output.log")
  log_error "$compose_output"
}
#######################################
# Mocks the docker compose self signed certificate configuration
# Globals:
#   DOCKER_COMPOSE_FILE
#   USE_LETSENCRYPT
#   USE_SELF_SIGNED_CERTS
#   test_output_dir
# Arguments:
#  None
#######################################
function run_compose_ss_configuration() {
  echo "Simulating Docker Compose configuration with self-signed certificates..."
  USE_LETSENCRYPT=false
  USE_SELF_SIGNED_CERTS=true
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  setup_self_signed_configuration_parameters
  configure_docker_compose 2>&1 | tee "${test_output_dir}/compose_ss_output.log"

  # Check for errors in the output and log them
  local compose_output
  compose_output=$(< "${test_output_dir}/compose_ss_output.log")
  log_error "$compose_output"
}

#######################################
# Mocks the docker compose development configuration (no ssl/letsencrypt)
# Globals:
#   DOCKER_COMPOSE_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_compose_dev_configuration() {
  echo "Simulating Docker Compose configuration for development..."
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  setup_dev_configuration_parameters
  configure_docker_compose 2>&1 | tee "${test_output_dir}/compose_dev_output.log"

  # Check for errors in the output and log them
  local compose_output
  compose_output=$(< "${test_output_dir}/compose_dev_output.log")
  log_error "$compose_output"
}

#######################################
# Mocks Backend/Express Dockerfile configuration
#######################################
function run_backend_container_configuration() {
  echo "Simulating backend configuration..."
  BACKEND_DOCKERFILE="${test_output_dir}/Backend.Dockerfile"
  setup_common_configuration_parameters
  configure_backend_docker 2>&1 | tee "${test_output_dir}/backend_docker_output.log"

  # Check for errors in the output and log them
  local docker_output
  docker_output=$(< "${test_output_dir}/backend_docker_output.log")
  log_error "$docker_output"
}

#######################################
# Mocks Frontend/React Dockerfile configuration
#######################################
function run_frontend_container_configuration() {
  echo "Simulating frontend configuration..."
  FRONTEND_DOCKERFILE="${test_output_dir}/Frontend.Dockerfile"
  setup_common_configuration_parameters
  configure_frontend_docker 2>&1 | tee "${test_output_dir}/frontend_docker_output.log"

  # Check for errors in the output and log them
  local docker_output
  docker_output=$(< "${test_output_dir}/frontend_docker_output.log")
  log_error "$docker_output"
}

#######################################
# Mocks the Certbot Dockerfile configuration
#######################################
function run_certbot_container_configuration() {
  echo "Simulating certbot configuration..."
  CERTBOT_DOCKERFILE="${test_output_dir}/Certbot.Dockerfile"
  setup_common_configuration_parameters
  setup_letsencrypt_configuration_parameters
  configure_certbot_docker 2>&1 | tee "${test_output_dir}/certbot_docker_output.log"

  # Check for errors in the output and log them
  local docker_output
  docker_output=$(< "${test_output_dir}/certbot_docker_output.log")
  log_error "$docker_output"
}

#######################################
# Setup common configuration parameters for NGINX and Docker Compose
# Globals:
#   BACKEND_PORT
#   DNS_RESOLVER
#   DOMAIN_NAME
#   EXPOSED_NGINX_PORT
#   NGINX_SSL_PORT
#   NODE_VERSION
#   RELEASE_BRANCH
#   SUBDOMAIN
#   TIMEOUT
# Arguments:
#  None
#######################################
function setup_common_configuration_parameters() {
  BACKEND_PORT=12345
  BACKEND_UPSTREAM_NAME="localhost"
  NGINX_PID="pid"
  NGINX_PID_FILE="${PROJECT_ROOT_DIR}/nginx.pid"
  NGINX_ERROR_LOG="error_log"
  NGINX_ERROR_LOG_FILE="${test_output_dir}/logs/error.log"
  NGINX_ACCESS_LOG="access_log"
  NGINX_ACCESS_LOG_FILE="${test_output_dir}/logs/access.log"
  NGINX_ERROR_LOG_LEVEL="error"
  RELEASE_BRANCH="full-release"
  NODE_VERSION="latest"
  NGINX_SSL_PORT="443"
  EXPOSED_NGINX_PORT=8080
  BACKEND_PORT=12345
  DNS_RESOLVER="8.8.8.8"
  TIMEOUT="5"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
}

#######################################
# Setup lets encrypt configuration parameters
# Globals:
#   USE_GZIP
#   USE_LETSENCRYPT
#   DRY_RUN_FLAG
#   EMAIL_FLAG
#   FORCE_RENEW_FLAG
#   HSTS_FLAG
#   MUST_STAPLE_FLAG
#   OSCP_STAPLING_FLAG
#   OVERWRITE_SELF_SIGNED_CERTS_FLAG
#   PRODUCTION_CERTS_FLAG
#   STRICT_PERMISSIONS_FLAG
#   UIR_FLAG
# Arguments:
#  None
#######################################
function setup_letsencrypt_configuration_parameters() {
  USE_LETSENCRYPT=true
  EMAIL_FLAG="--email example@example.com"
  PRODUCTION_CERTS_FLAG="--production-certs"
  DRY_RUN_FLAG="--dry-run"
  FORCE_RENEW_FLAG="--force-renew"
  OVERWRITE_SELF_SIGNED_CERTS_FLAG="--overwrite-cert-dirs"
  OCSP_STAPLING_FLAG="--staple-ocsp"
  MUST_STAPLE_FLAG="--must-staple"
  STRICT_PERMISSIONS_FLAG="--strict-permissions"
  HSTS_FLAG="--hsts"
  UIR_FLAG="--uir"
  USE_GZIP=true
}

#######################################
# Setup self signed certificate configuration parameters
# Globals:
#   NGINX_SSL_PORT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
function setup_self_signed_configuration_parameters() {
  NGINX_SSL_PORT="443"
  USE_SELF_SIGNED_CERTS=true
}

#######################################
# Setup development configuration parameters
# Globals:
#   USE_LETSENCRYPT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
function setup_dev_configuration_parameters() {
  USE_LETSENCRYPT=false
  USE_SELF_SIGNED_CERTS=false
}
