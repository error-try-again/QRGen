#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Arguments:
#   1
#   2
#   3
#   4
#######################################
handle_auto_install() {
  local auto_install_flag="${1:-false}"
  local use_letsencrypt="${2:-false}"
  local install_profile="${3:-}"
  local project_root_dir="${4:-}"

  prompt_for_auto_install
  if [[ ${auto_install_flag} == true ]]; then
    select_and_apply_profile "${install_profile}"

    cd "${project_root_dir}" || {
      print_multiple_messages "Failed to change directory to ${project_root_dir}"
      exit 1
    }

    if [[ ${use_letsencrypt} == "true" ]]; then
      construct_certbot_flags
    fi
  else
    cd "${project_root_dir}" || {
      print_multiple_messages "Failed to change directory to ${project_root_dir}"
      exit 1
    }
    prompt_for_release_install_mode
    prompt_disable_docker_build_cache
    prompt_for_domain_and_letsencrypt
    prompt_for_google_api_key
    prompt_for_gzip
  fi
}