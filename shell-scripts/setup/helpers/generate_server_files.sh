#!/bin/bash

# Produces server-side configuration files essential for backend and frontend operations.
generate_server_files() {
  echo "Creating server configuration files..."
  configure_backend_dotenv
  configure_frontend_dotenv
  echo "Configuring the Docker Express..."
  configure_backend_docker
  echo "Configuring the Docker NGINX Proxy..."
  configure_frontend_docker
  echo "Configuring the Docker Certbot..."
  configure_certbot_docker
  echo "Configuring Docker Compose..."
  configure_docker_compose
}
