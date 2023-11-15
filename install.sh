#!/bin/bash

# Exit on error, undefined variable, or pipe failure.
set -euo pipefail

# Change to the script's directory.
cd "$(dirname "$0")"

# Global associative arrays for directory references and configurations.
declare -A dirs internal_dirs ssl_paths certbot_volume_mappings

# Load dependencies only if the script is executed directly.
if [[ ${BASH_SOURCE[0]} == "${0}"   ]]; then
    # Load environment variables if .env file exists.
    if [[ -f .env ]]; then
      source .env
  else
      echo "Error: .env file not found."
      exit 1
  fi

  # Helper scripts for setting up the project environment.
  . ./shell-scripts/helpers/create_directory.sh
  . ./shell-scripts/helpers/copy_server_files.sh

  # Docker-related scripts to manage the container lifecycle.
  . ./shell-scripts/docker/docker_compose_exists.sh
  . ./shell-scripts/docker/docker_compose_down.sh
  . ./shell-scripts/docker/produce_docker_logs.sh
  . ./shell-scripts/docker/test_docker_env.sh

  # Networking scripts to ensure the necessary ports are available for use.
  . ./shell-scripts/networking/ensure_port_is_available.sh

  # Environment validation and setup, to ensure the system is ready for the project.
  . ./shell-scripts/environment/setup/generate/docker-rootless/setup_docker_rootless.sh
  . ./shell-scripts/environment/setup/generate/setup_project_directories.sh
  . ./shell-scripts/environment/setup/generate/generate_server_files.sh

  # Configuration scripts to generate the necessary files for the project.
  . ./shell-scripts/environment/setup/generate/configuration/backend/configure_backend_tsconfig.sh
  . ./shell-scripts/environment/setup/generate/configuration/backend/configure_backend_dockerfile.sh
  . ./shell-scripts/environment/setup/generate/configuration/general/configure_dotenv.sh
  . ./shell-scripts/environment/setup/generate/configuration/frontend/configure_frontend_dockerfile.sh
  . ./shell-scripts/environment/setup/generate/configuration/frontend/configure_nginx.sh
  . ./shell-scripts/environment/setup/generate/configuration/ssl/configure_certbot_dockerfile.sh
  . ./shell-scripts/environment/setup/generate/configuration/ssl/generate_self_signed_certificates.sh
  . ./shell-scripts/environment/setup/generate/configuration/compose/configure_docker_compose.sh

  # Helper scripts for user prompts and input.
  . ./shell-scripts/prompts/user_input.sh

  # File watcher for service restarts & certificate renewal.
  . ./shell-scripts/ssl/cert_file_watcher.sh

  # Generate the certificate renewal script for cron.
  . ./shell-scripts/ssl/generate_certbot_renewal.sh

  # The main operational scripts that carry out the required tasks.
  . ./shell-scripts/operations/operations.sh

  # Define global associative arrays.
  dirs=(
                   [BACKEND_DIR]="${PROJECT_ROOT_DIR}/backend"
                   [FRONTEND_DIR]="${PROJECT_ROOT_DIR}/frontend"
                   [SERVER_DIR]="${PROJECT_ROOT_DIR}/server"
                   [CERTBOT_DIR]="${PROJECT_ROOT_DIR}/certbot"
                   [CERTS_DIR]="${PROJECT_ROOT_DIR}/certs"
                   [WEBROOT_DIR]="${PROJECT_ROOT_DIR}/webroot"
                   [CERTS_DH_DIR]="${PROJECT_ROOT_DIR}/certs/dhparam"
  )

  internal_dirs=(
                   [INTERNAL_LETS_ENCRYPT_DIR]="/etc/letsencrypt"
                   [INTERNAL_LETS_ENCRYPT_LOGS_DIR]="/var/log/letsencrypt"
                   [INTERNAL_WEBROOT_DIR]="/usr/share/nginx/html"
                   [INTERNAL_CERTS_DH_DIR]="/etc/ssl/certs/dhparam"
  )

  ssl_paths=(
                   [PRIVKEY_PATH]="${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/privkey.pem"
                   [FULLCHAIN_PATH]="${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem"
                   [DH_PARAMS_PATH]="${internal_dirs[INTERNAL_CERTS_DH_DIR]}/dhparam-2048.pem"
  )

  certbot_volume_mappings=(
                   [LETS_ENCRYPT_VOLUME_MAPPING]="${dirs[CERTS_DIR]}:${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}"
                   [LETS_ENCRYPT_LOGS_VOLUME_MAPPING]="${dirs[CERTBOT_DIR]}/logs:${internal_dirs[INTERNAL_LETS_ENCRYPT_LOGS_DIR]}"
                   [CERTS_DH_VOLUME_MAPPING]="${dirs[CERTS_DH_DIR]}:${internal_dirs[INTERNAL_CERTS_DH_DIR]}"
                   [WEBROOT_VOLUME_MAPPING]="${dirs[WEBROOT_DIR]}:${internal_dirs[INTERNAL_WEBROOT_DIR]}"
  )
fi

# Setup project directories and configurations.
setup() {
    setup_project_directories
    setup_docker_rootless
    ensure_port_available "$NGINX_PORT"
    prompt_for_domain_and_letsencrypt
    generate_server_files
    configure_nginx
    build_and_run_docker
}

# Main entry point of the script.
main() {
  # This condition checks if the script is being sourced or executed.
  [[ ${BASH_SOURCE[0]} != "$0" ]] && echo "This script must be run, not sourced." && exit 1

  # Trap the SIGINT signal (Ctrl+C) and call the quit function.
  trap quit SIGINT

  user_prompt
}

# Check if script is being sourced or executed directly and call main if necessary.
[[ ${BASH_SOURCE[0]} == "${0}"   ]] && main
