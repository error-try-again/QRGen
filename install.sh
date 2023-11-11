#!/bin/bash

# A robust bash script setup with safe error handling.
set -euo pipefail # Exit on error, undefined variable, or pipe failure.
set +a            # Disable automatic export of all variables.

# Switch to the directory where the script is located to ensure
# relative paths are handled consistently.
cd "$(dirname "$0")"

# Source environment variables and function definitions from external scripts,
# allowing us to modularize and reuse code effectively.

# Load environment variables from a .env file.
. .env

# Helper scripts for setting up the project environment.
. ./shell-scripts/helpers/create-directory.sh
. ./shell-scripts/helpers/copy-server-files.sh

# Docker-related scripts to manage the container lifecycle.
. ./shell-scripts/docker/docker-compose-exists.sh
. ./shell-scripts/docker/docker-compose-down.sh
. ./shell-scripts/docker/produce-docker-logs.sh
. ./shell-scripts/docker/test-docker-env.sh

# Networking scripts to ensure the necessary ports are available for use.
. ./shell-scripts/networking/ensure-port-is-available.sh
. ./shell-scripts/networking/is-port-in-use.sh

# Environment validation and setup, to ensure the system is ready for the project.
. ./shell-scripts/environment/validation/test-xdg-runtime-dir.sh
. ./shell-scripts/environment/setup/generate/docker-rootless/setup-docker-rootless.sh
. ./shell-scripts/environment/setup/generate/setup-project-directories.sh
. ./shell-scripts/environment/setup/generate/generate-server-files.sh

# Configuration scripts to generate the necessary files for the project.
. ./shell-scripts/environment/setup/generate/configuration/backend/configure-backend-tsconfig.sh
. ./shell-scripts/environment/setup/generate/configuration/backend/configure-backend-dockerfile.sh
. ./shell-scripts/environment/setup/generate/configuration/general/configure-dotenv.sh
. ./shell-scripts/environment/setup/generate/configuration/frontend/configure-frontend-dockerfile.sh
. ./shell-scripts/environment/setup/generate/configuration/frontend/configure-nginx.sh
. ./shell-scripts/environment/setup/generate/configuration/ssl/configure-certbot-dockerfile.sh
. ./shell-scripts/environment/setup/generate/configuration/ssl/generate-self-signed-certificates.sh
. ./shell-scripts/environment/setup/generate/configuration/compose/configure-docker-compose.sh
. ./shell-scripts/prompts/user-input.sh

# The main operational scripts that carry out the required tasks.
. ./shell-scripts/operations/operations.sh

declare -A DIRS=(
  [BACKEND_DIR]="${PROJECT_ROOT_DIR}/backend"
  [FRONTEND_DIR]="${PROJECT_ROOT_DIR}/frontend"
  [SERVER_DIR]="${PROJECT_ROOT_DIR}/server"
  [CERTBOT_DIR]="${PROJECT_ROOT_DIR}/certbot"
  [CERTS_DIR]="${PROJECT_ROOT_DIR}/certs"
  [WEBROOT_DIR]="${PROJECT_ROOT_DIR}/webroot"
  [CERTS_DH_DIR]="${PROJECT_ROOT_DIR}/certs/dhparam"
)

# Docker Internal Directory References
declare -A INTERNAL_DIRS=(
  [INTERNAL_LETS_ENCRYPT_DIR]="/etc/letsencrypt"
  [INTERNAL_LETS_ENCRYPT_LOGS_DIR]="/var/log/letsencrypt"
  [INTERNAL_WEBROOT_DIR]="/usr/share/nginx/html"
  [INTERNAL_CERTS_DH_DIR]="/etc/ssl/certs/dhparam"
)

# SSL Certificate Paths
declare -A SSL_PATHS=(
  [PRIVKEY_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/privkey.pem"
  [FULLCHAIN_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem"
  [DH_PARAMS_PATH]="${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}/dhparam-2048.pem"
)

# Docker Volume Mappings for Nginx
declare -A NGINX_VOLUME_MAPPINGS=(
  [CERTS_VOLUME_MAPPING]="${DIRS[CERTS_DIR]}:${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}"
  [DH_VOLUME_MAPPING]="${DIRS[CERTS_DH_DIR]}:${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}"
)

# Docker Volume Mappings for Certbot
declare -A CERTBOT_VOLUME_MAPPINGS=(
  [LETS_ENCRYPT_VOLUME_MAPPING]="${DIRS[CERTS_DIR]}:${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}"
  [LETS_ENCRYPT_LOGS_VOLUME_MAPPING]="${DIRS[CERTBOT_DIR]}/logs:${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_LOGS_DIR]}"
  [CERTS_DH_VOLUME_MAPPING]="${DIRS[CERTS_DH_DIR]}:${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}"
  [WEBROOT_VOLUME_MAPPING]="${DIRS[WEBROOT_DIR]}:${INTERNAL_DIRS[INTERNAL_WEBROOT_DIR]}"
)

update_internal_ssl_paths() {
  SSL_PATHS[PRIVKEY_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/privkey.pem"
  SSL_PATHS[FULLCHAIN_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem"
  SSL_PATHS[DH_PARAMS_PATH]="${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}/dhparam-2048.pem"
}

# ---- Main Function/Entry ---- #

# Sets up the directories, configures Docker in rootless mode
# Generates necessary configuration files, and runs the Docker setup.
main() {
  setup_project_directories
  setup_docker_rootless
  ensure_port_available "$NGINX_PORT"
  prompt_for_domain_and_letsencrypt
  generate_server_files
  configure_nginx
  build_and_run_docker
}

user_prompt
