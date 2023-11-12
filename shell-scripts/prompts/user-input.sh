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
    "Run Setup") main ;;
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

# General-purpose prompt function for yes/no questions
prompt_yes_no() {
  local prompt="$1"
  local var_return="$2"
  local user_input
  read -rp "$prompt" user_input
  case "$user_input" in
  [yY][eE][sS] | [yY]) eval "$var_return"="yes" ;;
  *) eval "$var_return"="no" ;;
  esac
}

# Example usage of prompt_yes_no function
prompt_for_setup() {
  prompt_yes_no "Would you like to run the automatic ssl setup? (yes/no): "
  AUTOMATIC_SETUP
}

prompt_for_ssl_environment() {
  prompt_yes_no "Would you like to use a production SSL certificate? (yes/no): " USE_PRODUCTION_SSL
  [[ "$USE_PRODUCTION_SSL" == "yes" ]] && general_ssl_prompt
}

general_ssl_prompt() {
  prompt_for_letsencrypt_email && prompt_for_dry_run && prompt_for_overwrite_self_signed
}

prompt_for_auto_renew_ssl() {
  prompt_yes_no "Would you like to automatically renew your SSL certificate? (yes/no): " AUTO_RENEW_SSL
  [[ "$AUTO_RENEW_SSL" == "yes" ]]
}

prompt_for_letsencrypt_email() {
  local user_input=""
  local email_prompt="please enter your email address (or type 'skip' to skip): "

  read -rp "$email_prompt" user_input

  if [[ "$user_input" == "skip" ]]; then
    LETSENCRYPT_EMAIL=""
  elif [[ -z "$user_input" ]]; then
    echo "Error: Email address cannot be empty."
    prompt_for_letsencrypt_email
  else
    LETSENCRYPT_EMAIL="$user_input"
  fi
}

prompt_for_dry_run() {
  local user_input=""
  local dry_run_prompt="would you like to run a dry run? (yes/no): "

  read -rp "$dry_run_prompt" user_input

  if [[ "$user_input" == "yes" ]]; then
    USE_DRY_RUN="yes"
  else
    USE_DRY_RUN="no"
  fi
}

prompt_for_overwrite_self_signed() {
  local user_input=""
  local overwrite_prompt="Would you like to enable force-overwrites for
  letsencrypt certificates? This will allow overwriting of any existing
  certificates in the /live & /archive lineage directories. (yes/no): "

  read -rp "$overwrite_prompt" user_input

  if [[ "$user_input" == "yes" ]]; then
    OVERWRITE_SELF_SIGNED_CERTS_FLAG="--overwrite-cert-dirs"
  else
    OVERWRITE_SELF_SIGNED_CERTS_FLAG=""
  fi
}

prompt_with_validation() {
  local prompt_message="$1"
  local error_message="$2"
  local user_input=""

  while true; do
    read -rp "$prompt_message" user_input

    if [[ -z "$user_input" ]]; then
      echo "$error_message"
    else
      echo "$user_input"
      break
    fi
  done
}

prompt_for_regeneration() {
  local response
  read -rp "Do you want to regenerate the certificates in $1? [y/N]: " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0 # true, regenerate
  else
    return 1 # false, do not regenerate
  fi
}

prompt_for_domain_details() {
  prompt_yes_no "Would you like to specify a domain name other than the default (http://localhost) (yes/no)? " USE_CUSTOM_DOMAIN
  if [[ "$USE_CUSTOM_DOMAIN" == "yes" ]]; then
    DOMAIN_NAME=$(prompt_with_validation "Enter your domain name (e.g., example.com): " "Error: Domain name cannot be empty.")
    ORIGIN_URL="$BACKEND_SCHEME://$DOMAIN_NAME"
    ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
    echo "Using custom domain name: $ORIGIN_URL"

    prompt_yes_no "Would you like to specify a subdomain other than the default (none) (yes/no)? " USE_SUBDOMAIN
    if [[ "$USE_SUBDOMAIN" == "yes" ]]; then
      SUBDOMAIN=$(prompt_with_validation "Enter your subdomain name (e.g., www): " "Error: Subdomain name cannot be empty.")
      ORIGIN_URL="$BACKEND_SCHEME://$SUBDOMAIN.$DOMAIN_NAME"
      ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
      echo "Using custom subdomain: $ORIGIN_URL"
    fi
  else
    echo "Using default domain name: $DOMAIN_NAME"
  fi
}

prompt_for_letsencrypt_setup() {
  prompt_yes_no "Would you like to setup Let's Encrypt SSL for $DOMAIN_NAME (yes/no)? " USE_LETS_ENCRYPT
  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    echo "Setting up with Let's Encrypt SSL."
  else
    echo "Skipping Let's Encrypt setup."
  fi
}

prompt_for_domain_and_letsencrypt() {
  prompt_for_domain_details
  if [[ "$USE_CUSTOM_DOMAIN" == "yes" ]]; then
    prompt_for_letsencrypt_setup
  fi
}
