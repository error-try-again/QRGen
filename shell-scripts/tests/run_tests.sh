#!/bin/bash

# Run a series of configuration tests
run_tests() {
  echo "Running tests..."
  test_output_dir="${PROJECT_ROOT_DIR}/test_output"
  mkdir -p "${test_output_dir}"

  run_nginx_ss_configuration
  run_nginx_le_configuration
  run_nginx_dev_configuration
  run_compose_le_configuration
  run_compose_ss_configuration
  run_compose_dev_configuration
  run_backend_container_configuration
  run_frontend_container_configuration
  run_certbot_container_configuration

  echo "Tests complete."
}

run_nginx_ss_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_ss.conf"
  setup_common_configuration_parameters
  setup_self_signed_configuration_parameters
  configure_nginx
}

run_nginx_le_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_le.conf"
  setup_common_configuration_parameters
  setup_lets_encrypt_configuration_parameters
  configure_nginx
}

run_nginx_dev_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_dev.conf"
  setup_common_configuration_parameters
  setup_dev_configuration_parameters
  configure_nginx
}

run_compose_le_configuration() {
  echo "Simulating Docker Compose configuration with Let's Encrypt..."
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-le.yml"
  setup_common_configuration_parameters
  setup_lets_encrypt_configuration_parameters
  configure_docker_compose
}

run_compose_ss_configuration() {
  echo "Simulating Docker Compose configuration with self-signed certificates..."
  USE_LETS_ENCRYPT="no"
  USE_SELF_SIGNED_CERTS="yes"
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  setup_self_signed_configuration_parameters
  configure_docker_compose
}

run_compose_dev_configuration() {
  echo "Simulating Docker Compose configuration for development..."
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  setup_dev_configuration_parameters
  configure_docker_compose
}


run_backend_container_configuration() {
  echo "Simulating backend configuration..."
  BACKEND_DOCKERFILE="${test_output_dir}/Backend.Dockerfile"
  backend_files="backend/*"
  setup_common_configuration_parameters
  configure_backend_docker
}


run_frontend_container_configuration() {
  echo "Simulating frontend configuration..."
  FRONTEND_DOCKERFILE="${test_output_dir}/Frontend.Dockerfile"
  setup_common_configuration_parameters
  configure_frontend_docker
}

# Function to simulate running the Certbot configuration script
run_certbot_container_configuration() {
  echo "Simulating certbot configuration..."
  CERTBOT_DOCKERFILE="${test_output_dir}/Certbot.Dockerfile"
  setup_common_configuration_parameters
  setup_lets_encrypt_configuration_parameters
  configure_certbot_docker
}

# Setup common configuration parameters for NGINX and Docker Compose
setup_common_configuration_parameters() {
  NODE_VERSION="latest"
  NGINX_SSL_PORT="443"
  NGINX_PORT=8080
  BACKEND_PORT=3001
  DNS_RESOLVER="8.8.8.8"
  TIMEOUT="5s"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
}

setup_lets_encrypt_configuration_parameters() {
  USE_LETS_ENCRYPT="yes"
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

setup_self_signed_configuration_parameters() {
  NGINX_SSL_PORT="443"
  USE_SELF_SIGNED_CERTS="yes"
}

setup_dev_configuration_parameters() {
  USE_LETS_ENCRYPT="no"
  USE_SELF_SIGNED_CERTS="no"
}
