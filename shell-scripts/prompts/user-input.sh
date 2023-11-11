#!/bin/bash

# Script constants
PS3="Choose an option: "
options=(
  "Run Setup"
  "Cleanup"
  "Reload/Refresh"
  "Dump logs"
  "Update Project"
  "Enable SSL with Let's Encrypt"
  "Stop Project Docker Containers"
  "Prune All Docker Builds - Dangerous"
  "Quit"
)

# Main user prompt function
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"
  local opt
  select opt in "${options[@]}"; do
    case $opt in
    "Run Setup") prompt_for_setup && main ;;
    "Cleanup") cleanup ;;
    "Reload/Refresh") reload_project ;;
    "Dump logs") dump_logs ;;
    "Update Project") update_project ;;
    "Enable SSL with Let's Encrypt") prompt_for_ssl_environment ;;
    "Stop Project Docker Containers") bring_down_docker_compose ;;
    "Prune All Docker Builds - Dangerous") purge_builds ;;
    "Quit") exit 0 ;;
    *) echo "Invalid option. Try another one." ;;
    esac
    (($? == 0)) && break # if the function executed successfully, break the loop
  done
}

# General-purpose prompt function for yes/no questions and simple inputs
prompt_for_input() {
  local prompt="$1"
  local error_message="$2"
  local skip_check="${3:-}" # Optional parameter to allow skipping input
  local user_input

  while true; do
    read -rp "$prompt" user_input
    if [[ -n "$skip_check" ]] && [[ "$user_input" == "$skip_check" ]]; then
      echo ""
      return 0
    elif [[ -z "$user_input" ]]; then
      echo "$error_message"
    else
      echo "$user_input"
      return 0
    fi
  done
}

# Refactored prompts using the generic function 'prompt_for_input'
prompt_for_setup() {
  AUTOMATIC_SETUP=$(prompt_for_input "Would you like to run the automatic setup? (yes/no): " "Please answer yes or no.")
}

prompt_for_ssl_environment() {
  USE_PRODUCTION_SSL=$(prompt_for_input "Would you like to use a production SSL certificate? (yes/no): " "Please answer yes or no.")
  [[ "$USE_PRODUCTION_SSL" == "yes" ]] && prompt_for_auto_renew_ssl
}

prompt_for_auto_renew_ssl() {
  AUTO_RENEW_SSL=$(prompt_for_input "Would you like to automatically renew your SSL certificate? (yes/no): " "Please answer yes or no.")
  [[ "$AUTO_RENEW_SSL" == "yes" ]] && prompt_for_letsencrypt_email
}

prompt_for_letsencrypt_email() {
  LETSENCRYPT_EMAIL=$(prompt_for_input "Please enter your email address (or type 'skip' to skip): " "Error: Email address cannot be empty." "skip")
}

prompt_for_dry_run() {
  USE_DRY_RUN=$(
    prompt_for_input "Would you like to run a dry run? (yes/no): " "Please answer yes or no."
  )

  [[ "$USE_DRY_RUN" == "yes" ]] && DRY_RUN_FLAG="--dry-run"
}

prompt_for_overwrite_self_signed() {
  OVERWRITE_SELF_SIGNED_CERTS_FLAG=$(prompt_for_input "Would you like to overwrite the existing self-signed certificates? (yes/no): " "Please answer yes or no.")
  if [[ "$OVERWRITE_SELF_SIGNED_CERTS_FLAG" == "yes" ]]; then
    OVERWRITE_SELF_SIGNED_CERTS_FLAG="--overwrite-cert-dirs"
  else
    OVERWRITE_SELF_SIGNED_CERTS_FLAG=""
  fi
}

prompt_for_regeneration() {
  local user_response
  user_response=$(prompt_for_input "Do you want to regenerate the certificates in $1?
  [y/N]: " "Please answer yes or no.")
  if [[ "$user_response" == "yes" ]]; then
    return 0 # true, regenerate
  else
    return 1 # false, do not regenerate
  fi
}

prompt_for_default_certs() {
  local user_response
  user_response=$(prompt_for_input "Would you like to generate default certificates?
  (yes/no): " "Please answer yes or no.")
  if [[ "$user_response" == "yes" ]]; then
    generate_self_signed_certificates
  else
    echo "Please place the required files in the expected directories or generate them."
    return 1
  fi
}

prompt_for_domain_and_letsencrypt() {
  DOMAIN_NAME=$(prompt_for_input "Enter your root domain name (default http://localhost): " "Error: Domain name cannot be empty." "default")
  USE_CUSTOM_DOMAIN="no"
  [[ "$DOMAIN_NAME" != "default" ]] && USE_CUSTOM_DOMAIN="yes"
  if [[ "$USE_CUSTOM_DOMAIN" == "yes" ]]; then
    ORIGIN_URL="$BACKEND_SCHEME://$DOMAIN_NAME"
    ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
    echo "Using custom domain name: $ORIGIN_URL"
    prompt_for_letsencrypt_setup
  else
    DOMAIN_NAME="http://localhost"
    echo "Using default domain name: $DOMAIN_NAME"
  fi
}

prompt_for_letsencrypt_setup() {
  USE_LETS_ENCRYPT=$(prompt_for_input "Would you like to setup Let's Encrypt SSL for $DOMAIN_NAME (yes/no)? " "Please answer yes or no.")
  [[ "$USE_LETS_ENCRYPT" == "yes" ]] && echo "Setting up with Let's Encrypt SSL."
}
