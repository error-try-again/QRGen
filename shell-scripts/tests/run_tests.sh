#!/bin/bash

# Run a series of configuration tests
run_tests() {
  echo "Running tests..."
  test_output_dir="${PROJECT_ROOT_DIR}/test_output"
  mkdir -p "${test_output_dir}"

  # Run individual configuration tests
  run_nginx_test_configuration
  run_compose_le_configuration
  run_compose_ss_configuration
  run_compose_dev_configuration
  run_backend_test_configuration
  run_frontend_test_configuration
  run_certbot_test_configuration

  echo "Tests complete."
}

# Function to simulate running the NGINX configuration script
run_nginx_test_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx.conf"
  setup_common_configuration_parameters
  configure_nginx
}

run_compose_le_configuration() {
  echo "Simulating Docker Compose configuration with Let's Encrypt..."
  USE_LETS_ENCRYPT="yes"
  USE_SELF_SIGNED_CERTS="no"
  force_renew_flag="--force-renew"
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-le.yml"
  setup_common_configuration_parameters
  configure_docker_compose
}

run_compose_ss_configuration() {
  echo "Simulating Docker Compose configuration with self-signed certificates..."
  USE_LETS_ENCRYPT="no"
  USE_SELF_SIGNED_CERTS="yes"
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  configure_docker_compose
}

run_compose_dev_configuration() {
  echo "Simulating Docker Compose configuration for development..."
  USE_LETS_ENCRYPT="no"
  USE_SELF_SIGNED_CERTS="no"
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  configure_docker_compose
}


# Function to simulate running the backend configuration script
run_backend_test_configuration() {
  echo "Simulating backend configuration..."
  BACKEND_DOCKERFILE="${test_output_dir}/Backend.Dockerfile"
  NODE_VERSION="latest"
  backend_files="backend/*"
  BACKEND_PORT=3001
  configure_backend_docker
}

# Function to simulate running the frontend configuration script
run_frontend_test_configuration() {
  echo "Simulating frontend configuration..."
  FRONTEND_DOCKERFILE="${test_output_dir}/Frontend.Dockerfile"  # Corrected variable name
  NODE_VERSION="latest"
  NGINX_PORT=8080
  configure_frontend_docker
}

# Function to simulate running the Certbot configuration script
run_certbot_test_configuration() {
  echo "Simulating certbot configuration..."
  CERTBOT_DOCKERFILE="${test_output_dir}/Certbot.Dockerfile"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
  configure_certbot_docker
}

# Setup common configuration parameters for NGINX and Docker Compose
setup_common_configuration_parameters() {
  NGINX_SSL_PORT=443
  DNS_RESOLVER="8.8.8.8"
  TIMEOUT="5s"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
  TLS_PROTOCOL_SUPPORT="restricted"

  email_flag="--email example@example.com"
  production_certs_flag="--production-certs"
  dry_run_flag="--dry-run"
  force_renew_flag="--force-renew"
  overwrite_self_signed_certs_flag="--overwrite-cert-dirs"
  ocsp_stapling_flag="--staple-ocsp"
  must_staple_flag="--must-staple"
  strict_permissions_flag="--strict-permissions"
  hsts_flag="--hsts"
  uir_flag="--uir"
}
