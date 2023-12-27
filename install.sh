#!/usr/bin/env bash

set -euo pipefail

#######################################
# Sources all the files in the project.
# Arguments:
#  None
#######################################
source_files() {
    # Directories and their contents
  source ./shell/config/apply_profile.sh

  # Parser scripts
  source ./shell/config/parser/initialize_command_flags.sh
  source ./shell/config/parser/dispatch_command.sh
  source ./shell/config/parser/display_help.sh
  source ./shell/config/parser/parse_options.sh

  # Operations scripts
  source ./shell/operations/backup_replace_file.sh
  source ./shell/operations/build_run_docker.sh
  source ./shell/operations/check_certbot_success.sh
  source ./shell/operations/check_flag_removal.sh
  source ./shell/operations/check_jq_exists.sh
  source ./shell/operations/common_build_operations.sh
  source ./shell/operations/dump_logs.sh
  source ./shell/operations/handle_ambiguous_networks.sh
  source ./shell/operations/handle_certs.sh
  source ./shell/operations/handle_staging_flags.sh
  source ./shell/operations/modify_docker_compose.sh
  source ./shell/operations/pre_flight.sh
  source ./shell/operations/purge_builds.sh
  source ./shell/operations/rebuild_rerun_certbot.sh
  source ./shell/operations/remove_conflicting_containers.sh
  source ./shell/operations/remove_dry_run_flag.sh
  source ./shell/operations/remove_staging_flag.sh
  source ./shell/operations/restart_services.sh
  source ./shell/operations/run_backend_service.sh
  source ./shell/operations/run_certbot_dry_run.sh
  source ./shell/operations/run_certbot_service.sh
  source ./shell/operations/run_frontend_service.sh
  source ./shell/operations/setup.sh
  source ./shell/operations/uninstall.sh
  source ./shell/operations/update_project.sh
  source ./shell/operations/validate_and_load_dotenv.sh
  source ./shell/operations/validate_installer_profile.sh
  source ./shell/operations/wait_for_certbot_completion.sh

  # Prompts scripts
  source ./shell/prompts/custom_install_prompt.sh
  source ./shell/prompts/disable_docker_cache_prompt.sh
  source ./shell/prompts/evaluate_valid_input_string.sh
  source ./shell/prompts/handle_user_selection.sh
  source ./shell/prompts/numeric_prompt.sh
  source ./shell/prompts/prompt_for_dhparam_regen.sh
  source ./shell/prompts/prompt_for_dhparam_strength.sh
  source ./shell/prompts/prompt_for_domain_and_letsencrypt.sh
  source ./shell/prompts/prompt_for_domain_details.sh
  source ./shell/prompts/prompt_for_google_api_key.sh
  source ./shell/prompts/prompt_for_gzip.sh
  source ./shell/prompts/prompt_for_install_mode.sh
  source ./shell/prompts/prompt_for_letsencrypt_options.sh
  source ./shell/prompts/prompt_for_self_signed.sh
  source ./shell/prompts/prompt_for_ssl.sh
  source ./shell/prompts/prompt_with_validation.sh
  source ./shell/prompts/user_input.sh
  source ./shell/prompts/yes_no_prompt.sh

  # Selection choices scripts
  source ./shell/prompts/selection_choices/certbot_image_selected.sh
  source ./shell/prompts/selection_choices/construct_certbot_flags.sh
  source ./shell/prompts/selection_choices/handle_certbot_image_selection.sh
  source ./shell/prompts/selection_choices/select_tls_version.sh

  # Setup helpers scripts
  source ./shell/setup/helpers/copy_server_files.sh
  source ./shell/setup/helpers/create_directory.sh
  source ./shell/setup/helpers/generate_server_files.sh
  source ./shell/setup/helpers/setup_project_directories.sh

  # Setup sitemap scripts
  source ./shell/setup/sitemap/configure_frontend_sitemap.sh

  # Setup dotenv_configure scripts
  source ./shell/setup/dotenv_configure/configure_backend_dotenv.sh
  source ./shell/setup/dotenv_configure/configure_frontend_dotenv.sh

  # Setup nginx scripts
  source ./shell/setup/nginx/configure_nginx.sh

  # Setup docker-rootless scripts
  source ./shell/setup/docker-rootless/setup_docker_rootless.sh

  # Docker helper scripts
  source ./shell/setup/docker/helpers/docker_compose_down.sh
  source ./shell/setup/docker/helpers/docker_compose_exists.sh
  source ./shell/setup/docker/helpers/produce_docker_logs.sh
  source ./shell/setup/docker/helpers/test_docker_env.sh

  # Docker containers frontend scripts
  source ./shell/setup/docker/containers/frontend/configure_frontend_dockerfile.sh

  # Docker containers certbot scripts
  source ./shell/setup/docker/containers/certbot/configure_certbot_dockerfile.sh

  # Docker containers backend scripts
  source ./shell/setup/docker/containers/backend/configure_backend_dockerfile.sh

  # Docker compose scripts
  source ./shell/setup/docker/compose/configure_docker_compose.sh

  # Setup self-signed scripts
  source ./shell/setup/self-signed/generate_self_signed_certificates.sh

  # Networking scripts
  source ./shell/networking/ensure_port_is_available.sh

  # Profiles scripts
  source ./shell/profiles/automatic_production_selection.sh
  source ./shell/profiles/automatic_staging_selection.sh
  source ./shell/profiles/automation_production_reload_selection.sh

  # Flags scripts
  source ./shell/flags/enable_ssl.sh
  source ./shell/flags/enable_letsencrypt.sh

  source ./shell/mocks/run_mocks.sh

  source ./shell/operations/certbot/build_certbot_service.sh

  source ./shell/ssl/generate_certbot_renewal.sh
}

#######################################
# Exits the script cleanly.
# Arguments:
#  None
#######################################
quit() {
  echo -e "\nQuiting..."
  exit 0
}

#######################################
# Main function to run the script.
# Arguments:
#  None
#######################################
main() {
  # Ensures that the script is not sourced. This is to prevent the script from being run in the wrong environment.
  [[ ${BASH_SOURCE[0]} != "$0" ]] && echo "This install.sh script must be run, not sourced." && exit 1

  # Trap the SIGINT signal (Ctrl+C) and call the quit function.
  trap quit SIGINT

  # Ensures that the script can be run from anywhere as it changes the directory to the script's directory.
  cd "$(dirname "$0")"

  # Source all the files in the project.
  source_files

  # Validate and load the .env file, which maintains a list of globals and environment variables.
  validate_and_load_dotenv

  # Check if jq exists, essential for parsing the json installer profile.
  check_jq_exists

  # Validate the installer profile configuration if it exists.
  validate_installer_profile_configuration

  # Initialize the default command flags. E.g. --setup --help, --version, --debug, etc.
  initialize_command_flags

  # Parse the flag options and dispatch the command flags, otherwise displays the user_prompt TUI.
  dispatch_command "$@"
}

main "$@"
