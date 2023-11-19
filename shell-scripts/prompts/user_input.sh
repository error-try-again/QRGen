#!/bin/bash

. .env

#######################################
# description
# Arguments:
#  None
#######################################
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"
  local opt
  select opt in "Run Setup" "Uninstall" "Reload/Refresh" "Dump logs" "Update Project" "Stop Project Docker Containers" "Prune All Docker Builds - Dangerous" "Quit"; do
    case $opt in
      "Run Setup") setup ;;
      "Uninstall") uninstall ;;
      "Reload/Refresh") reload ;;
      "Dump logs") dump_logs ;;
      "Update Project") update_project ;;
      "Stop Project Docker Containers") stop_containers ;;
      "Prune All Docker Builds - Dangerous") purge_builds ;;
      "Quit") quit ;;
      *) echo "Invalid option. Try another one." ;;
    esac
    (($? == 0)) && break
  done
  echo "Thanks for using the QR Code Generator setup script!"
}

#######################################
# description
# Arguments:
#  None
#######################################
custom_install_prompt() {
    prompt_for_input "Please enter your Let's Encrypt email or type 'skip' to skip: " "Error: Email address cannot be empty." LETSENCRYPT_EMAIL
    prompt_yes_no "Would you like to use a production SSL certificate? (yes/no): " USE_PRODUCTION_SSL
    prompt_yes_no "Would you like to use a dry run? (yes/no): " USE_DRY_RUN
    prompt_yes_no "Would you like to force current certificate renewal? (yes/no): " USE_FORCE_RENEW
    prompt_yes_no "Would you like to automatically renew your SSL certificate? (yes/no): " USE_AUTO_RENEW_SSL
    prompt_yes_no "Would you like to enable HSTS? (yes/no): " USE_HSTS
    prompt_yes_no "Would you like to enable OCSP Stapling? (yes/no): " USE_OCSP_STAPLING
    prompt_yes_no "Would you like to enable Must Staple? (yes/no): " USE_MUST_STAPLE
    prompt_yes_no "Would you like to enable Strict Permissions? (yes/no): " USE_STRICT_PERMISSIONS
    prompt_yes_no "Would you like to enable UIR (Unique Identifier for Revocation)? (yes/no): " USE_UIR
    prompt_yes_no "Would you like to overwrite self-signed certificates? (yes/no): " USE_OVERWRITE_SELF_SIGNED_CERTS
}

# bashsupport disable=BP5006
automatic_staging_selection() {
      LETSENCRYPT_EMAIL="skip"
      USE_AUTO_RENEW_SSL="yes"
      REGENERATE_SSL_CERTS="yes"
      USE_HSTS="yes"
      USE_UIR="yes"
      USE_DRY_RUN="yes"
      USE_OVERWRITE_SELF_SIGNED_CERTS="yes"
      USE_PRODUCTION_SSL="no"
      USE_STRICT_PERMISSIONS="no"
      USE_OCSP_STAPLING="no"
      USE_MUST_STAPLE="no"
}

# bashsupport disable=BP5006
automation_production_selection() {
      LETSENCRYPT_EMAIL="skip"
      USE_AUTO_RENEW_SSL="yes"
      REGENERATE_SSL_CERTS="yes"
      USE_HSTS="yes"
      USE_UIR="yes"
      USE_OVERWRITE_SELF_SIGNED_CERTS="yes"
      USE_DRY_RUN="yes"
      USE_PRODUCTION_SSL="yes"
      USE_OCSP_STAPLING="yes"
      USE_STRICT_PERMISSIONS="no"
      USE_MUST_STAPLE="no"
}

#######################################
# Sets the environment variable flag for Express to use SSL
# Arguments:
#  None
#######################################
# bashsupport disable=BP2001
set_ssl_flag() {
   USE_SSL="true"
}

#######################################
# description
# Globals:
#   LETSENCRYPT_EMAIL
#   USE_DRY_RUN
#   USE_FORCE_RENEW
#   USE_HSTS
#   USE_MUST_STAPLE
#   USE_OCSP_STAPLING
#   USE_OVERWRITE_SELF_SIGNED_CERTS
#   USE_PRODUCTION_SSL
#   USE_STRICT_PERMISSIONS
#   USE_UIR
#   dry_run_flag
#   email_flag
#   force_renew_flag
#   hsts_flag
#   must_staple_flag
#   ocsp_stapling_flag
#   overwrite_self_signed_certs_flag
#   production_certs_flag
#   strict_permissions_flag
#   uir_flag
# Arguments:
#  None
#######################################
construct_certbot_flags() {
  email_flag=$([[ $LETSENCRYPT_EMAIL == "skip"   ]] && echo "--register-unsafely-without-email" || echo "--email $LETSENCRYPT_EMAIL")
  production_certs_flag=$([[ $USE_PRODUCTION_SSL == "yes"   ]] && echo "" || echo "--staging")
  dry_run_flag=$([[ $USE_DRY_RUN == "yes"   ]] && echo "--dry-run" || echo "")
  force_renew_flag=$([[ $USE_FORCE_RENEW == "yes"   ]] && echo "--force-renewal" || echo "")
  overwrite_self_signed_certs_flag=$([[ $USE_OVERWRITE_SELF_SIGNED_CERTS == "yes"   ]] && echo "--overwrite-cert-dirs" || echo "")
  ocsp_stapling_flag=$([[ $USE_OCSP_STAPLING == "yes"   ]] && echo "--staple-ocsp" || echo "")
  must_staple_flag=$([[ $USE_MUST_STAPLE == "yes"   ]] && echo "--must-staple" || echo "")
  strict_permissions_flag=$([[ $USE_STRICT_PERMISSIONS == "yes"   ]] && echo "--strict-permissions" || echo "")
  hsts_flag=$([[ $USE_HSTS == "yes"   ]] && echo "--hsts" || echo "")
  uir_flag=$([[ $USE_UIR == "yes"   ]] && echo "--uir" || echo "")
}

# Function to prompt for yes/no answers
prompt_yes_no() {
  local prompt="$1"
  local result_var="$2"
  local yn
  echo "$prompt"
  while true; do
    read -r yn
    case "$yn" in
      [yY] | [yY][eE][sS])
        eval "$result_var=yes"
        break
        ;;
      [nN] | [nN][oO])
        eval "$result_var=no"
        break
        ;;
      *)
        echo "Invalid selection. Please enter yes or no."
        ;;
    esac
  done
}

prompt_numeric() {
  local prompt_message=$1
  local var_name=$2
  local input

  # Read the numeric input
  read -rp "$prompt_message" input
  while ! [[ $input =~ ^[0-9]+$   ]]; do
    echo "Please enter a valid number."
    read -rp "$prompt_message" input
  done
  eval "$var_name"="'$input'"
}

prompt_for_ssl() {
  # Prompt for using Let's Encrypt SSL
  echo "1: Use Let's Encrypt SSL"
  echo "2: Use self-signed SSL certificates"
  echo "3: Do not enable SSL"
  prompt_numeric "Please enter your choice (1/2/3): " SSL_CHOICE

  case $SSL_CHOICE in
    1)
      set_ssl_flag
      echo "1: Run automatic staging setup for Let's Encrypt SSL (Recommended for testing)"
      echo "2: Run automatic production setup for Let's Encrypt SSL (Recommended for production)"
      echo "3: Run custom setup for Let's Encrypt SSL"
      prompt_numeric "Please enter your choice (1/2): " AUTO_SETUP_CHOICE
      if [[ $AUTO_SETUP_CHOICE == 1 ]]; then
        USE_LETS_ENCRYPT="yes"
        automatic_staging_selection
    elif [[ $AUTO_SETUP_CHOICE == 2 ]]; then
        USE_LETS_ENCRYPT="yes"
        automation_production_selection
    elif   [[ $AUTO_SETUP_CHOICE == 3 ]]; then
        USE_LETS_ENCRYPT="yes"
        custom_install_prompt
    else
        echo "Invalid choice. Please enter 1, 2, or 3."
    fi
      ;;
    2)
      USE_SELF_SIGNED_CERTS="yes"
      set_ssl_flag
      ;;
    3)
      echo "SSL will not be enabled."
      ;;
    *)
      echo "Invalid choice. Please enter 1, 2, or 3."
      ;;
  esac
}

# Function to prompt user input with a custom message and error handling
prompt_for_input() {
  local prompt_message="$1"
  local error_message="$2"
  local result_var="$3"
  local user_input
  while true; do
    read -rp "$prompt_message" user_input
    if [[ -n $user_input   ]]; then
      eval "$result_var='$user_input'"
      break
    else
      echo "$error_message"
    fi
  done
}

#######################################
# description
# Globals:
#   REGENERATE_SSL_CERTS
# Arguments:
#   1
# Returns:
#   0 ...
#   1 ...
#######################################
prompt_for_regeneration() {
  # Override default behavior if REGENERATE_SSL_CERTS is set
  if  [[ $REGENERATE_SSL_CERTS == "yes"   ]]; then
    return 0 # true, regenerate
  fi

  local response
  read -rp "Do you want to regenerate the certificates in $1? [y/N]: " response

  if [[ $response =~ ^([yY][eE][sS]|[yY])$  ]]; then
    return 0 # true, regenerate
  else
    return 1 # false, do not regenerate
  fi
}

#######################################
# description
# Globals:
#   BACKEND_SCHEME
#   ORIGIN_PORT
#   USE_CUSTOM_DOMAIN
#   USE_SUBDOMAIN
#   DOMAIN_NAME
#   origin
#   origin_url
#   SUBDOMAIN
# Arguments:
#  None
#######################################
prompt_for_domain_details() {
  prompt_yes_no "Would you like to specify a domain name other than the default (http://localhost) (yes/no)? " USE_CUSTOM_DOMAIN
  if [[ $USE_CUSTOM_DOMAIN == "yes"   ]]; then
    DOMAIN_NAME=$(prompt_with_validation "Enter your domain name (e.g., example.com): " "Error: Domain name cannot be empty.")
    local origin_url
    origin_url="$BACKEND_SCHEME://$DOMAIN_NAME"
    ORIGIN="$origin_url:$ORIGIN_PORT"
    echo "Using custom domain name: $origin_url"

    prompt_yes_no "Would you like to specify a subdomain other than the default (none) (yes/no)? " USE_SUBDOMAIN
    if [[ $USE_SUBDOMAIN == "yes"   ]]; then
      SUBDOMAIN=$(prompt_with_validation "Enter your subdomain name (e.g., www): " "Error: subdomain name cannot be empty.")
      origin_url="$BACKEND_SCHEME://$SUBDOMAIN.$DOMAIN_NAME"
      ORIGIN="$origin_url:$ORIGIN_PORT"
      echo "Using custom subdomain: $origin_url"
    fi
  else
    echo "Using default domain name: $DOMAIN_NAME"
  fi
}

#######################################
# description
# Globals:
#   USE_CUSTOM_DOMAIN
# Arguments:
#  None
#######################################
prompt_for_domain_and_letsencrypt() {
  prompt_for_domain_details
  if [[ $USE_CUSTOM_DOMAIN == "yes"   ]]; then
    prompt_for_ssl
    construct_certbot_flags
  fi
}

#######################################
# description
# Arguments:
#   1
#   2
#######################################
prompt_with_validation() {
  local prompt_message="$1"
  local error_message="$2"
  local user_input=""

  while true; do
    read -rp "$prompt_message" user_input

    if [[ -z $user_input   ]]; then
      echo "$error_message"
    else
      echo "$user_input"
      break
    fi
  done
}
