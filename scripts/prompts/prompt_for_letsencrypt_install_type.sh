#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts for Let's Encrypt SSL options and runs the appropriate setup.
# Globals:
#   AUTO_INSTALL
# Arguments:
#   None
#######################################
function prompt_for_letsencrypt_install_type() {
  print_messages "1: Run automatic staging setup for Let's Encrypt SSL (Recommended for testing)"
  print_messages "2: Run automatic production setup for Let's Encrypt SSL (Recommended for production)"
  print_messages "3: Run automatic reload of production setup for Let's Encrypt SSL (Keeps existing certificates and reloads server)"
  print_messages "4: Run custom setup for Let's Encrypt SSL (Advanced)"
  prompt_numeric "Please enter your choice (1/2/3/4): " AUTO_INSTALL
  case ${AUTO_INSTALL} in
    1) automatic_staging_selection ;;
    2) automatic_production_selection ;;
    3) automatic_production_reload_selection ;;
    4) prompt_for_custom_letsencrypt_install ;;
    *) print_messages "Invalid choice, please enter 1, 2, 3, or 4." ;;
  esac
}
