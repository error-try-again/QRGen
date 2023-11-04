#!/bin/bash

# Users choose between setting up the project, cleaning up, reloading the project, or dumping Docker logs.
# Serves as the entry point to the script.
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"

  PS3="Choose an option (1/2/3/4/5/6/7/8/9): "
  local options=(
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
  local opt

  select opt in "${options[@]}"; do
    case $opt in
    "Run Setup")
      main
      break
      ;;
    "Cleanup")
      cleanup
      break
      ;;
    "Dump logs")
      #      bring_down_docker_compose
      dump_logs
      break
      ;;
    "Reload/Refresh")
      reload_project
      break
      ;;
    "Update Project")
      update_project
      break
      ;;
    "Enable SSL with Let's Encrypt")
      USE_LETS_ENCRYPT="yes"
      main
      break
      ;;
    "Stop Project Docker Containers")
      bring_down_docker_compose
      break
      ;;
    "Prune All Docker Builds - Dangerous")
      purge_builds
      break
      ;;
    "Quit")
      quit
      ;;
    *)
      echo "Invalid option"
      ;;
    esac
  done
}

# ---- User Input ---- #
# Prompts user with a message and ensures a non-empty response.
# Returns the response when it's non-empty.
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

prompt_for_default_certs() {
  local user_response=""
  local default_certs_prompt="Would you like to generate default certificates? (yes/no): "

  read -rp "$default_certs_prompt" user_response

  if [[ "$user_response" == "yes" ]]; then
    generate_default_certificates
  else
    echo "Please place the required files in the expected directories or generate them."
    return 1
  fi
}

# Prompts the user for domain and subdomain details.
prompt_for_domain_details() {
  local user_response=""
  local custom_domain_prompt="Would you like to specify a domain name other than the default (http://localhost) (yes/no)? "
  local domain_prompt="Enter your domain name (e.g., example.com): "
  local domain_error_message="Error: Domain name cannot be empty."
  local custom_subdomain_prompt="Would you like to specify a subdomain (e.g., www.example.com, void.example.com) other than the default (none) (yes/no)? "
  local subdomain_prompt="Enter your subdomain name (e.g., www): "
  local subdomain_error_message="Error: Subdomain name cannot be empty."

  # Ask if the user wants to specify a different domain name.
  read -rp "$custom_domain_prompt" user_response

  if [[ "$user_response" == "yes" ]]; then
    USE_CUSTOM_DOMAIN="yes"
    DOMAIN_NAME=$(prompt_with_validation "$domain_prompt" "$domain_error_message")
    ORIGIN_URL="$BACKEND_SCHEME://$DOMAIN_NAME"
    ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
    echo "Using custom domain name: $ORIGIN_URL"

    # Ask if the user wants to specify a subdomain.
    read -rp "$custom_subdomain_prompt" user_response
    if [[ "$user_response" == "yes" ]]; then
      SUBDOMAIN=$(prompt_with_validation "$subdomain_prompt" "$subdomain_error_message")
      ORIGIN_URL="$BACKEND_SCHEME://$SUBDOMAIN.$DOMAIN_NAME"
      ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
      echo "Using custom domain name: $ORIGIN_URL"
    fi
  else
    echo "Using default domain name: $DOMAIN_NAME"
    USE_CUSTOM_DOMAIN="no"
  fi
}

# Prompts the user whether they would like to setup Let's Encrypt SSL for their domain.
prompt_for_letsencrypt_setup() {
  local user_response=""
  local setup_letsencrypt_prompt="Would you like to setup Let's Encrypt SSL for $DOMAIN_NAME (yes/no)? "

  # Ask if the user wants to set up Let's Encrypt SSL.
  read -rp "$setup_letsencrypt_prompt" user_response

  echo "$user_response"

  if [[ "$user_response" == "yes" ]]; then
    USE_LETS_ENCRYPT="yes"
    echo "Setting up with Let's Encrypt SSL."
  else
    echo "Skipping Let's Encrypt setup."
  fi
}

# Prompts the user for domain details and Let's Encrypt setup.
prompt_for_domain_and_letsencrypt() {
  prompt_for_domain_details
  if [[ $USE_CUSTOM_DOMAIN == "yes" ]]; then
    prompt_for_letsencrypt_setup
  fi
}
