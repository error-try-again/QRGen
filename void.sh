#!/usr/bin/env bash

set -euo pipefail

#######################################
# Quits the script and displays a simple message to the user.
# Arguments:
#  None
#######################################
quit() {
  echo -e "\nThanks for using the installer script. Exiting now."
  exit 1
}

#######################################
# description
# Arguments:
#  None
#######################################
source_configurations() {
  source installer/util/config.sh
  source_global_configurations
}

#######################################
# Source the project files required for the script to run.
# Arguments:
#  None
#######################################
source_project_files() {
  source installer/util/report_timestamp.sh
  source installer/util/create_directory_and_log.sh
  source installer/util/setup_directory_structure.sh
  source installer/util/print_message.sh
  source installer/util/print_multiple_messages.sh
  source installer/util/initialize_and_dispatch_command.sh
  source installer/util/backup_existing_file.sh
  source installer/util/backup_and_replace_file.sh
  source installer/util/echo_indented.sh
  source installer/util/join_array_with_commas.sh
  source installer/util/insert_into_bashrc.sh
  source installer/util/update_project.sh
  source installer/util/profile_builder.sh
  source installer/util/generate_robots.sh
  source installer/util/generate_sitemap.sh
  source installer/util/nginx.sh
  source installer/util/main_operations.sh
  source installer/util/flag_management.sh
  source installer/util/manage_port_availability.sh
  source installer/util/manage_ssl.sh
  source installer/util/manage_docker.sh
  source installer/util/manage_certbot.sh
  source installer/util/manage_dockerfile_generation.sh
  source installer/util/manage_compose_operating_mode.sh
  source installer/util/validate_file_exists.sh
  source installer/util/check_command_exists.sh
  source installer/util/initialize_rootless_docker.sh
  source installer/util/dump_logs.sh

  source installer/util/compose_definition_builder.sh
  source installer/util/generate_frontend_dotenv.sh
  source installer/util/generate_backend_dotenv.sh

  source installer/util/handle_auto_install.sh
  source installer/util/profile_selection_applicators.sh
  source installer/util/generate_nginx_mime_types.sh

  source installer/prompts/prompts.sh
}

#######################################
# Handles the main entry point of the script. It initializes the command flags, parses the command flags, and dispatches
# the command flags to the appropriate functions. If no command flags are provided, it displays the user prompt TUI.
# Globals:
#   BASH_SOURCE
# Arguments:
#  None
#######################################
main() {
  # Ensures that the script is not sourced. This is to prevent the script from being run in the wrong environment.
  [[ ${BASH_SOURCE[0]} != "$0" ]] && echo "This install.sh script must be run, not sourced." && exit 1

  # Trap the SIGINT signal (Ctrl+C) and call the quit function.
  trap quit SIGINT

  local working_dir
  working_dir="$(pwd)"

  # Export working directory to ensure that even if the script is run from another directory, it will still work.
  declare -xrg working_dir

  # Ensures that the script can be run from anywhere as it changes the directory to the script's directory.
  cd "$(dirname "$0")"

  # Source default global configuration variables
  source_configurations

  # Source the project files required for the script to run.
  source_project_files

  # Check if jq exists, essential for parsing the json installer profile.
  check_command_exists "jq" "jq is required to parse the installer profile."

  # Initialize the default command flags. E.g. --setup --help, --version, --debug, etc.
  initialize_command_flags

  # Parse the flag options and dispatch the command flags, otherwise displays the user_prompt TUI.
  dispatch_command "$@"
}

# Tracks the time it takes to run the script.
time main "$@"