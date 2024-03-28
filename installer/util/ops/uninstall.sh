#!/usr/bin/env bash

set -euo pipefail

#######################################
# Uninstallation and cleanup functions, now dynamically handling service resources
# Globals:
#   project_root_dir
# Arguments:
#  None
#######################################
uninstall() {
  verify_docker
  if [[ -d ${project_root_dir} ]]; then
    local delete_project_dir
    read -r -p "Do you want to delete the project directory ${project_root_dir}? [y/N]: " delete_project_dir
    if [[ ${delete_project_dir} =~ ^[Yy]$ ]]; then
      print_multiple_messages "Purging the project docker environments..."
      purge
      print_multiple_messages "Uninstalling the project..."
      rm -rf "${project_root_dir}"
      print_message "Project directory ${project_root_dir} deleted."
    else
      print_message "Project directory ${project_root_dir} not deleted."
    fi
  fi

  print_message "Uninstallation complete."
}