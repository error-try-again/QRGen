#!/usr/bin/env bash

set -euo pipefail

#######################################
# Setup project directories and configurations.
# Globals:
# NGINX_PORT
# Arguments:
#  None
#######################################
setup() {
  setup_project_directories
  setup_docker_rootless
  ensure_port_is_available "$NGINX_PORT" "auto"
  if [[ $PROMPT_BYPASS == true ]]; then
    echo "Skipping prompts..."
  else
    prompt_for_install_mode
    disable_docker_build_caching_prompt
    prompt_for_domain_and_letsencrypt
    prompt_for_google_api_key
    prompt_for_gzip
  fi
  generate_server_files
  configure_nginx
  build_and_run_docker
}
