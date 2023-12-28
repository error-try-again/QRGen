#!/usr/bin/env bash

set -euo pipefail

#######################################
# Sources all the files in the project.
# Arguments:
#  None
#######################################
function source_files() {
    # Parser scripts
    source ./scripts/config/parser/dispatch_command.sh
    source ./scripts/config/parser/display_help.sh
    source ./scripts/config/parser/initialize_command_flags.sh
    source ./scripts/config/parser/options_parser.sh

    # Profiles scripts
    source ./scripts/config/profiles/apply_profile.sh
    source ./scripts/config/profiles/automatic_production_reload_selection.sh
    source ./scripts/config/profiles/automatic_production_selection.sh
    source ./scripts/config/profiles/automatic_staging_selection.sh

    # Flags scripts
    source ./scripts/flags/construct_certbot_flags.sh
    source ./scripts/flags/enable_ssl.sh

    # Flag Removal scripts
    source ./scripts/flags/flag_removal/remove_staging_flags.sh
    source ./scripts/flags/flag_removal/remove_certbot_command_flags_compose.sh
    source ./scripts/flags/flag_removal/check_flag_removal.sh
    source ./scripts/flags/flag_removal/remove_dry_run_flag.sh
    source ./scripts/flags/flag_removal/remove_staging_flag.sh

    # Operations - Networking
    source ./scripts/operations/networking/ensure_port_is_available.sh
    source ./scripts/operations/networking/handle_ambiguous_networks.sh

    # Operations - Primary
    source ./scripts/operations/primary/dump_logs.sh
    source ./scripts/operations/primary/purge_builds.sh
    source ./scripts/operations/primary/setup.sh
    source ./scripts/operations/primary/uninstall.sh
    source ./scripts/operations/primary/update_project.sh
    source ./scripts/operations/primary/docker_compose_down.sh

    # Operations - Service
    source ./scripts/operations/service/build_run_docker.sh
    source ./scripts/operations/service/common_build_operations.sh
    source ./scripts/operations/service/pre_flight.sh
    source ./scripts/operations/service/rebuild_rerun_certbot.sh
    source ./scripts/operations/service/remove_conflicting_containers.sh
    source ./scripts/operations/service/restart_services.sh
    source ./scripts/operations/service/run_backend_service.sh
    source ./scripts/operations/service/run_certbot_dry_run.sh
    source ./scripts/operations/service/run_certbot_service.sh
    source ./scripts/operations/service/run_frontend_service.sh

    # Operations - Validation
    source ./scripts/operations/validation/validate_and_load_dotenv.sh
    source ./scripts/operations/validation/validate_installer_profile.sh
    source ./scripts/operations/validation/validate_project_root.sh
    source ./scripts/operations/validation/check_jq_exists.sh

    # Prompts scripts
    source ./scripts/prompts/prompt_for_custom_certbot_install.sh
    source ./scripts/prompts/prompt_disable_docker_build_cache.sh
    source ./scripts/prompts/prompt_and_validate_input.sh
    source ./scripts/prompts/prompt_user_selection_switch.sh
    source ./scripts/prompts/prompt_numeric.sh
    source ./scripts/prompts/prompt_for_dhparam_regen.sh
    source ./scripts/prompts/prompt_for_dhparam_strength.sh
    source ./scripts/prompts/prompt_for_domain_and_letsencrypt.sh
    source ./scripts/prompts/prompt_for_domain_details.sh
    source ./scripts/prompts/prompt_for_google_api_key.sh
    source ./scripts/prompts/prompt_for_gzip.sh
    source ./scripts/prompts/prompt_for_install_mode.sh
    source ./scripts/prompts/prompt_for_letsencrypt_options.sh
    source ./scripts/prompts/prompt_for_self_signed.sh
    source ./scripts/prompts/prompt_for_ssl.sh
    source ./scripts/prompts/prompt_with_validation.sh
    source ./scripts/prompts/prompt_user.sh
    source ./scripts/prompts/prompt_yes_no.sh
    source ./scripts/prompts/prompt_for_letsencrypt.sh
    source ./scripts/prompts/prompt_tls_selection.sh

    # Setup - Docker Compose Configuration Scripts
    source ./scripts/setup/docker/compose/configure_docker_compose.sh
    source ./scripts/setup/docker/compose/generate_certonly_command.sh
    source ./scripts/setup/docker/compose/create_network_definition.sh
    source ./scripts/setup/docker/compose/create_volume_definition.sh
    source ./scripts/setup/docker/compose/create_service_definition.sh
    source ./scripts/setup/docker/compose/configure_compose_letsencrypt_mode.sh
    source ./scripts/setup/docker/compose/configure_compose_self_signed_mode.sh
    source ./scripts/setup/docker/compose/configure_compose_http_mode.sh
    source ./scripts/setup/docker/compose/assemble_docker_compose.sh
    source ./scripts/setup/docker/compose/initialize_compose_variables.sh
    source ./scripts/setup/docker/compose/join_with_commas.sh

    # Setup - Dockerfile Configuration Scripts
    source ./scripts/setup/docker/containers/backend/configure_backend_dockerfile.sh
    source ./scripts/setup/docker/containers/certbot/configure_certbot_dockerfile.sh
    source ./scripts/setup/docker/containers/frontend/configure_frontend_dockerfile.sh

    # Setup - Certbot
    source ./scripts/operations/certbot/generate_certbot_renewal.sh
    source ./scripts/operations/certbot/wait_for_certbot_completion.sh
    source ./scripts/operations/certbot/check_certbot_success.sh

    # Setup - Common
    source ./scripts/setup/docker/common/docker_compose_exists.sh
    source ./scripts/setup/docker/common/test_docker_env.sh

    # Setup - Docker Rootless
    source ./scripts/setup/docker/rootless/setup_docker_rootless.sh

    # Setup - Dotenv Configure
    source ./scripts/setup/dotenv/configure_backend_dotenv.sh
    source ./scripts/setup/dotenv/configure_frontend_dotenv.sh

    # Setup - Util Scripts
    source ./scripts/operations/util/create_directory.sh
    source ./scripts/operations/util/configure_server_files.sh
    source ./scripts/operations/util/setup_project_directories.sh
    source ./scripts/operations/util/backup_replace_file.sh

    # Setup - Nginx
    source ./scripts/setup/docker/containers/frontend/configure_nginx_config.sh

    # Setup - Self-signed
    source ./scripts/operations/certificates/generate_self_signed_certificates.sh
    source ./scripts/operations/certificates/handle_certs.sh

    # Setup - Sitemap
    source ./scripts/setup/sitemap/configure_frontend_sitemap.sh

    # Setup - Robots
    source ./scripts/setup/robots/configure_frontend_robots.sh

    # Test Mocks
    source ./scripts/tests/mocks/run_mocks.sh

}

#######################################
# Exits the script cleanly.
# Arguments:
#  None
#######################################
function quit() {
  echo -e "\nQuiting..."
  exit 0
}

#######################################
# Main function to run the script.
# Arguments:
#  None
#######################################
function main() {
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
