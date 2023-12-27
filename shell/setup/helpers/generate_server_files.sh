#!/usr/bin/env bash

set -euo pipefail

#######################################
# Create a default robots.txt file with no restrictions
# Globals:
#   None
# Arguments:
#  None
#######################################
create_default_robots_txt() {
    cat <<- EOF > "${ROBOTS_FILE}"
User-agent: *
Disallow:
EOF
  echo "Default robots.txt created."
}

# Produces server-side configuration files essential for backend and frontend operations.
generate_server_files() {
  echo "Creating server configuration files..."
  configure_backend_dotenv
  configure_frontend_dotenv
  echo "Configuring the Docker Express..."
  configure_backend_docker
  echo "Configuring the site map..."
  configure_frontend_sitemap
  echo "Configuring default robots.txt..."
  create_default_robots_txt
  echo "Configuring the frontend Docker environment..."
  configure_frontend_docker
  echo "Configuring the Docker Certbot Image..."
  configure_certbot_docker
  echo "Configuring Docker Compose..."
  configure_docker_compose
}
