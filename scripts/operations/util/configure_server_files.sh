#!/usr/bin/env bash

set -euo pipefail

# Produces server-side configuration files essential for backend and frontend operations.
function configure_server_files() {
  echo "Creating server configuration files..."
  configure_backend_dotenv
  configure_frontend_dotenv
  echo "Configuring the Docker Express..."
  configure_backend_docker
  echo "Configuring the site map..."
  configure_frontend_sitemap
  echo "Configuring default robots.txt..."
  configure_frontend_robots
  echo "Configuring the frontend Docker environment..."
  configure_frontend_docker
  echo "Configuring the Docker Certbot Image..."
  configure_certbot_docker
  echo "Configuring Docker Compose..."
  configure_docker_compose
}
