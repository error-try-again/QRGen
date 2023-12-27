#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Run a series of configuration mocks (manually test the configuration scripts)
# Globals:
#   PROJECT_ROOT_DIR
#   test_output_dir
# Arguments:
#  None
#######################################
run_mocks() {
  echo "Running mocks..."
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

  echo "Mocks complete."
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
  setup_letsencrypt_configuration_parameters
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
  setup_letsencrypt_configuration_parameters
  configure_docker_compose
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
run_compose_ss_configuration() {
  echo "Simulating Docker Compose configuration with self-signed certificates..."
  USE_LETSENCRYPT=false
  USE_SELF_SIGNED_CERTS=true
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
#   test_output_dir
# Arguments:
#  None
#######################################
run_backend_container_configuration() {
  echo "Simulating backend configuration..."
  BACKEND_DOCKERFILE="${test_output_dir}/Backend.Dockerfile"
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
  setup_letsencrypt_configuration_parameters
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
#   RELEASE_BRANCH
#   SUBDOMAIN
#   TIMEOUT
# Arguments:
#  None
#######################################
setup_common_configuration_parameters() {
  RELEASE_BRANCH="full-release"
  NODE_VERSION="latest"
  NGINX_SSL_PORT="443"
  NGINX_PORT=8080
  BACKEND_PORT=3001
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
setup_letsencrypt_configuration_parameters() {
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
setup_self_signed_configuration_parameters() {
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
setup_dev_configuration_parameters() {
  USE_LETSENCRYPT=false
  USE_SELF_SIGNED_CERTS=false
}
