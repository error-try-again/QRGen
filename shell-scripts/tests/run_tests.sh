#!/bin/bash

run_tests() {
  echo "Running tests..."
  test_output_dir="${PROJECT_ROOT_DIR}/test_output"
  mkdir -p "${test_output_dir}"
  run_nginx_test_configuration
  run_compose_test_configuration
  run_backend_test_configuration
  run_frontend_test_configuration
  run_certbot_test_configuration
  echo "Tests complete."
}

# Function to simulate running the NGINX configuration script
run_nginx_test_configuration() {
  echo "Simulating NGINX configuration..."
  NGINX_CONF_FILE="${test_output_dir}/nginx.conf"
  USE_LETS_ENCRYPT="yes"
  USE_SELF_SIGNED_CERTS="no"
  NGINX_SSL_PORT=443
  DNS_RESOLVER="1.1.1.1"
  TIMEOUT="5s"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
  TLS_PROTOCOL_SUPPORT="restricted"
  USE_LETS_ENCRYPT="yes"
  DOMAIN_NAME="example.com"
  configure_nginx
}

run_compose_test_configuration() {
  echo "Simulating docker-compose configuration..."
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker_compose.yml"
  USE_LETS_ENCRYPT="yes"
  USE_SELF_SIGNED_CERTS="no"
  NGINX_SSL_PORT=443
  DNS_RESOLVER="1.1.1.1"
  TIMEOUT="5s"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
  TLS_PROTOCOL_SUPPORT="restricted"
  USE_LETS_ENCRYPT="yes"
  DOMAIN_NAME="example.com"
  configure_docker_compose
}

run_backend_test_configuration() {
  echo "Simulating backend configuration..."
  BACKEND_DOCKERFILE="${BACKEND_DIR}/Dockerfile"
  NODE_VERSION="latest"
  backend_files="backend/*"
  BACKEND_PORT=3000
  configure_backend_docker
}

run_frontend_test_configuration() {
  echo "Simulating frontend configuration..."
  BACKEND_DOCKERFILE="${test_output_dir}/Dockerfile"
  NODE_VERSION="latest"
  NGINX_PORT=8080
  configure_frontend_docker

}

run_certbot_test_configuration() {
  echo "Simulating certbot configuration..."
  CERTBOT_DOCKERFILE="${test_output_dir}/Dockerfile"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
  configure_certbot_docker
}
