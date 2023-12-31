#!/usr/bin/env bash

set -euo pipefail

# Produces server-side configuration files essential for backend and frontend operations.
function configure_server_files() {
print_messages "Building server configuration files..."
  configure_backend_dotenv
  configure_frontend_dotenv
  generate_backend_dockerfile
  configure_frontend_sitemap
  configure_frontend_robots
  generate_frontend_dockerfile
  generate_certbot_dockerfile
  generate_docker_compose
}
