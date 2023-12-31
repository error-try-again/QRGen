#!/usr/bin/env bash

set -euo pipefail

# Produces server-side configuration files essential for backend and frontend operations.
function configure_server_files() {
  print_messages "Creating server configuration files..."
  configure_backend_dotenv
  configure_frontend_dotenv
  print_messages "Configuring the Docker Express..."
  generate_backend_dockerfile
  print_messages "Configuring the site map..."
  configure_frontend_sitemap
  print_messages "Configuring default robots.txt..."
  configure_frontend_robots
  print_messages "Configuring the frontend Docker environment..."
  generate_frontend_dockerfile
  print_messages "Configuring the Docker Certbot Image..."
  generate_certbot_dockerfile
  print_messages "Configuring Docker Compose..."
  generate_docker_compose
}
