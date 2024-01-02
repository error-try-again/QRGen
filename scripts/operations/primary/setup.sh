#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Arguments:
#   1
#######################################
function handle_skip_prompts() {
  local bypass
  bypass=$1
  if [[ ${bypass} == true ]]; then
      print_messages "Skipping prompts..."
  fi
}

# Handle auto install
function handle_auto_install() {
  prompt_for_auto_install
  if [[ ${AUTO_INSTALL} == true ]]; then
      select_and_apply_profile "${INSTALL_PROFILE}"
  else
    prompt_for_release_install_mode
    prompt_disable_docker_build_cache
    prompt_for_domain_and_letsencrypt
    prompt_for_google_api_key
    prompt_for_gzip
  fi
}

#######################################
# Setup project directories and configurations.
# Globals:
# EXPOSED_NGINX_PORT
# Arguments:
#  None
#######################################
function setup() {
    setup_project_directories
    setup_docker_rootless
    ensure_port_is_available "${EXPOSED_NGINX_PORT}" "auto"
    handle_skip_prompts "${PROMPT_BYPASS}"
    handle_auto_install
    configure_server_files
    generate_nginx_config
    build_and_run_docker
}
