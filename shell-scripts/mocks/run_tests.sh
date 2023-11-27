#!/bin/bash


#######################################
# Run a series of configuration mocks (manually test the configuration scripts)
# Globals:
#   PROJECT_ROOT_DIR
#   test_output_dir
# Arguments:
#  None
#######################################
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

#######################################
# Mocks the self signed certificate generation nginx configuration
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
run_nginx_ss_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_ss.conf"
  setup_common_configuration_parameters
  setup_self_signed_configuration_parameters
  configure_nginx
}

#######################################
# Mocks the lets encrypt nginx configuration (faux certbot configuration)
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
run_nginx_le_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_le.conf"
  setup_common_configuration_parameters
  setup_lets_encrypt_configuration_parameters
  configure_nginx
}

#######################################
# Mocks the development nginx configuration (no ssl/letsencrypt)
# Globals:
#   NGINX_CONF_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
run_nginx_dev_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx_dev.conf"
  setup_common_configuration_parameters
  setup_dev_configuration_parameters
  configure_nginx
}

#######################################
# Mocks the docker compose lets encrypt configuration (faux certbot configuration)
# Globals:
#   DOCKER_COMPOSE_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
run_compose_le_configuration() {
  echo "Simulating Docker Compose configuration with Let's Encrypt..."
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-le.yml"
  setup_common_configuration_parameters
  setup_lets_encrypt_configuration_parameters
  configure_docker_compose
}

#######################################
# Mocks the docker compose self signed certificate configuration
# Globals:
#   DOCKER_COMPOSE_FILE
#   USE_LETS_ENCRYPT
#   USE_SELF_SIGNED_CERTS
#   test_output_dir
# Arguments:
#  None
#######################################
run_compose_ss_configuration() {
  echo "Simulating Docker Compose configuration with self-signed certificates..."
  USE_LETS_ENCRYPT="no"
  USE_SELF_SIGNED_CERTS="yes"
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  setup_self_signed_configuration_parameters
  configure_docker_compose
}

#######################################
# Mocks the docker compose development configuration (no ssl/letsencrypt)
# Globals:
#   DOCKER_COMPOSE_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
run_compose_dev_configuration() {
  echo "Simulating Docker Compose configuration for development..."
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose-ss.yml"
  setup_common_configuration_parameters
  setup_dev_configuration_parameters
  configure_docker_compose
}


#######################################
# Mocks Backend/Express Dockerfile configuration
# Globals:
#   BACKEND_DOCKERFILE
#   backend_files
#   test_output_dir
# Arguments:
#  None
#######################################
run_backend_container_configuration() {
  echo "Simulating backend configuration..."
  BACKEND_DOCKERFILE="${test_output_dir}/Backend.Dockerfile"
  backend_files="backend/*"
  setup_common_configuration_parameters
  configure_backend_docker
}


#######################################
# Mocks Frontend/React Dockerfile configuration
# Globals:
#   FRONTEND_DOCKERFILE
#   test_output_dir
# Arguments:
#  None
#######################################
run_frontend_container_configuration() {
  echo "Simulating frontend configuration..."
  FRONTEND_DOCKERFILE="${test_output_dir}/Frontend.Dockerfile"
  setup_common_configuration_parameters
  configure_frontend_docker
}


#######################################
# Mocks the certbot Dockerfile configuration
# Globals:
#   CERTBOT_DOCKERFILE
#   test_output_dir
# Arguments:
#  None
#######################################
run_certbot_container_configuration() {
  echo "Simulating certbot configuration..."
  CERTBOT_DOCKERFILE="${test_output_dir}/Certbot.Dockerfile"
  setup_common_configuration_parameters
  setup_lets_encrypt_configuration_parameters
  configure_certbot_docker
}


#######################################
# Setup common configuration parameters for NGINX and Docker Compose
# Globals:
#   BACKEND_PORT
#   DNS_RESOLVER
#   DOMAIN_NAME
#   NGINX_PORT
#   NGINX_SSL_PORT
#   NODE_VERSION
#   SUBDOMAIN
#   TIMEOUT
# Arguments:
#  None
#######################################
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

#######################################
# Setup lets encrypt configuration parameters
# Globals:
#   USE_LETS_ENCRYPT
#   dry_run_flag
#   email_flag
#   force_renew_flag
#   hsts_flag
#   must_staple_flag
#   ocsp_stapling_flag
#   overwrite_self_signed_certs_flag
#   production_certs_flag
#   strict_permissions_flag
#   uir_flag
# Arguments:
#  None
#######################################
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

#######################################
# Setup self signed certificate configuration parameters
# Globals:
#   NGINX_SSL_PORT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
setup_self_signed_configuration_parameters() {
  NGINX_SSL_PORT="443"
  USE_SELF_SIGNED_CERTS="yes"
}

#######################################
# Setup development configuration parameters
# Globals:
#   USE_LETS_ENCRYPT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
setup_dev_configuration_parameters() {
  USE_LETS_ENCRYPT="no"
  USE_SELF_SIGNED_CERTS="no"
}
