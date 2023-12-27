#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts for Let's Encrypt SSL options
# Globals:
#   AUTO_SETUP_CHOICE
# Arguments:
#   None
#######################################
prompt_for_lets_encrypt_options() {
  enable_ssl
      echo "1: Run automatic staging setup for Let's Encrypt SSL (Recommended for testing)"
      echo "2: Run automatic production setup for Let's Encrypt SSL (Recommended for production)"
      echo "3: Run automatic reload of production setup for Let's Encrypt SSL (Keeps existing certificates and reloads server)"
      echo "4: Run custom setup for Let's Encrypt SSL (Advanced)"
      numeric_prompt "Please enter your choice (1/2/3/4): " AUTO_SETUP_CHOICE
  case $AUTO_SETUP_CHOICE in
    1) automatic_staging_selection ;;
    2) automatic_production_selection ;;
    3) automatic_production_reload_selection ;;
    4) custom_install_prompt ;;
    *)
       echo "Invalid choice, please enter 1, 2, 3, or 4." ;;
  esac
}
