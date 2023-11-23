#!/bin/bash

# Produces server-side configuration files essential for backend and frontend operations.
generate_server_files() {
  echo "Creating server configuration files..."
  configure_frontend_docker
  echo "Configuring the Docker Certbot..."
  configure_certbot_docker
  echo "Configuring Docker Compose..."
  configure_docker_compose
}
