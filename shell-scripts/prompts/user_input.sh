#!/usr/bin/env bash
# bashsupport disable=BP5006

. .env

#######################################
# Provides a basic TUI/menu for the user to select from, and then calls the appropriate function.
# Globals:
#   PS3
# Arguments:
#  None
#######################################
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"
  local opt
  PS3='Select: '
  select opt in "Run Setup" "Run Mock Configuration" "Uninstall" "Dump logs" "Update Project" "Stop Project Docker Containers" "Prune All Docker Builds - Dangerous" "Quit"; do
    case $opt in
      "Run Setup") setup ;;
      "Run Mock Configuration") run_mocks ;;
      "Uninstall") uninstall ;;
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
# Custom prompt mechanism for the user to select from - allows for more flexibility than the automatic SSL setup.
# Arguments:
#  None
#######################################
custom_install_prompt() {
  prompt_yes_no "Would you like to build with Certbot? (Recommended)" BUILD_CERTBOT_IMAGE
  if [[ $BUILD_CERTBOT_IMAGE == "yes" ]]; then
    prompt_for_input "Please enter your Let's Encrypt email or type 'skip' to skip: " "Error: Email address cannot be empty." LETSENCRYPT_EMAIL
    prompt_yes_no "Would you like to use a production SSL certificate?" USE_PRODUCTION_SSL
    prompt_yes_no "Would you like to use a dry run?" USE_DRY_RUN
    prompt_yes_no "Would you like to force current certificate renewal?" USE_FORCE_RENEW
    prompt_yes_no "Would you like to automatically renew your SSL certificate?" USE_AUTO_RENEW_SSL
    prompt_yes_no "Would you like to enable HSTS (Recommended)?" USE_HSTS
    prompt_yes_no "Would you like to enable OCSP Stapling (Recommended)?" USE_OCSP_STAPLING
    prompt_yes_no "Would you like to enable Must Staple (Not Recommended)?" USE_MUST_STAPLE
    prompt_yes_no "Would you like to enable UIR (Unique Identifier for Revocation)?" USE_UIR
    prompt_yes_no "Would you like to enable Strict Permissions (Not Recommended)?" USE_STRICT_PERMISSIONS
    prompt_yes_no "Would you like to overwrite existing certificates?" USE_OVERWRITE_SELF_SIGNED_CERTS
    prompt_yes_no "Would you like to enable TLSv1.3? (Recommended): " USE_TLS13
    prompt_yes_no "Would you like to enable TLSv1.2?" USE_TLS12
  else
    prompt_yes_no "Would you like to enable TLSv1.3? (Recommended): " USE_TLS13
    prompt_yes_no "Would you like to enable TLSv1.2?" USE_TLS12
  fi
}

#######################################
# Provides some sane defaults for automatic staging/ssl setup.
# Globals:
#   BUILD_CERTBOT_IMAGE
#   LETSENCRYPT_EMAIL
#   REGENERATE_SSL_CERTS
#   USE_AUTO_RENEW_SSL
#   USE_DRY_RUN
#   USE_HSTS
#   USE_MUST_STAPLE
#   USE_OCSP_STAPLING
#   USE_OVERWRITE_SELF_SIGNED_CERTS
#   USE_PRODUCTION_SSL
#   USE_STRICT_PERMISSIONS
#   USE_TLS12
#   USE_TLS13
#   USE_UIR
# Arguments:
#  None
#######################################
automatic_staging_selection() {
  LETSENCRYPT_EMAIL="skip"
  BUILD_CERTBOT_IMAGE="yes"
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
  USE_TLS13="yes"
  USE_TLS12="no"
}

#######################################
# Provides some sane defaults for reloading the project.
# Globals:
#   BUILD_CERTBOT_IMAGE
#   LETSENCRYPT_EMAIL
#   USE_AUTO_RENEW_SSL
#   USE_DRY_RUN
#   USE_HSTS
#   USE_MUST_STAPLE
#   USE_OCSP_STAPLING
#   USE_OVERWRITE_SELF_SIGNED_CERTS
#   USE_PRODUCTION_SSL
#   USE_STRICT_PERMISSIONS
#   USE_TLS12
#   USE_TLS13
#   USE_UIR
# Arguments:
#  None
#######################################
automatic_production_reload_selection() {
  LETSENCRYPT_EMAIL="skip"
  USE_AUTO_RENEW_SSL="yes"
  BUILD_CERTBOT_IMAGE="no"
  USE_HSTS="yes"
  USE_UIR="yes"
  USE_OVERWRITE_SELF_SIGNED_CERTS="no"
  USE_DRY_RUN="yes"
  USE_PRODUCTION_SSL="yes"
  USE_OCSP_STAPLING="yes"
  USE_STRICT_PERMISSIONS="no"
  USE_MUST_STAPLE="no"
  USE_TLS13="yes"
  USE_TLS12="no"
}

#######################################
# Provides some sane defaults for automatic production/ssl setup.
# Globals:
#   BUILD_CERTBOT_IMAGE
#   LETSENCRYPT_EMAIL
#   USE_AUTO_RENEW_SSL
#   USE_DRY_RUN
#   USE_HSTS
#   USE_MUST_STAPLE
#   USE_OCSP_STAPLING
#   USE_OVERWRITE_SELF_SIGNED_CERTS
#   USE_PRODUCTION_SSL
#   USE_STRICT_PERMISSIONS
#   USE_TLS12
#   USE_TLS13
#   USE_UIR
# Arguments:
#  None
#######################################
automation_production_selection() {
  LETSENCRYPT_EMAIL="skip"
  BUILD_CERTBOT_IMAGE="yes"
  USE_AUTO_RENEW_SSL="yes"
  USE_HSTS="yes"
  USE_UIR="yes"
  USE_OVERWRITE_SELF_SIGNED_CERTS="yes"
  USE_DRY_RUN="yes"
  USE_PRODUCTION_SSL="yes"
  USE_OCSP_STAPLING="yes"
  USE_STRICT_PERMISSIONS="no"
  USE_MUST_STAPLE="no"
  USE_TLS13="yes"
  USE_TLS12="no"
}

#######################################
# Sets the USE_SSL flag to true.
# This will be picked up by the backend .env file if the Express server is being used.
# Globals:
#   USE_SSL
# Arguments:
#  None
#######################################
set_ssl_flag() {
  USE_SSL="true"
}

#######################################
# Sets the global flag for using Let's Encrypt to be used throughout the script.
# Globals:
#   USE_LETS_ENCRYPT
# Arguments:
#  None
#######################################
set_letsencrypt_flag() {
  USE_LETS_ENCRYPT="yes"
}

#######################################
# Sets the global flag for using self-signed certificates to be used throughout the script.
# Globals:
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
set_self_signed_flag() {
  USE_SELF_SIGNED_CERTS="yes"
}

#######################################
# Echos the relevant flag depending on the user's choice.
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
  email_flag=$([[ $LETSENCRYPT_EMAIL == "skip" ]] && echo "--register-unsafely-without-email" || echo "--email $LETSENCRYPT_EMAIL")
  production_certs_flag=$([[ $USE_PRODUCTION_SSL == "yes" ]] && echo "" || echo "--staging")
  dry_run_flag=$([[ $USE_DRY_RUN == "yes" ]] && echo "--dry-run" || echo "")
  force_renew_flag=$([[ $USE_FORCE_RENEW == "yes" ]] && echo "--force-renewal" || echo "")
  overwrite_self_signed_certs_flag=$([[ $USE_OVERWRITE_SELF_SIGNED_CERTS == "yes" ]] && echo "--overwrite-cert-dirs" || echo "")
  ocsp_stapling_flag=$([[ $USE_OCSP_STAPLING == "yes" ]] && echo "--staple-ocsp" || echo "")
  must_staple_flag=$([[ $USE_MUST_STAPLE == "yes" ]] && echo "--must-staple" || echo "")
  strict_permissions_flag=$([[ $USE_STRICT_PERMISSIONS == "yes" ]] && echo "--strict-permissions" || echo "")
  hsts_flag=$([[ $USE_HSTS == "yes" ]] && echo "--hsts" || echo "")
  uir_flag=$([[ $USE_UIR == "yes" ]] && echo "--uir" || echo "")
}

#######################################
# Prompt the user to disable cache for the Docker build.
# Allows for a clean build if the user has made changes to the project.
# Arguments:
#  None
#######################################
disable_docker_build_caching_prompt() {
  prompt_yes_no "Would you like to disable Docker build caching for this run?" DISABLE_DOCKER_CACHING
}

#######################################
# Prompts the user to select whether they want to use self-signed certificates.
# Globals:
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
prompt_for_self_signed_certificates() {
  prompt_yes_no "Would you like to enable self-signed certificates?" USE_SELF_SIGNED_CERTS
  if [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then
    set_ssl_flag
  fi
}

#######################################
# Generic prompt that handles yes/no responses and evaluates the result.
# Arguments:
#   1
#   2
#######################################
prompt_yes_no() {
  local prompt_message="$1"
  local result_var="$2"
  local choice
  while true; do
    read -rp "$prompt_message [Y/n]: " choice
    case "${choice,,}" in  # Convert to lowercase for easier matching
      yes | y)
               eval "$result_var=yes"
                                       break
                                             ;;
      no | n)
              eval "$result_var=no"
                                     break
                                           ;;
      "")
          eval "$result_var=yes"
                                  break
                                        ;; # Default to 'yes' if the user just presses enter
      *) echo "Invalid input. Please enter 'yes' or 'no'." ;;
    esac
  done
}

#######################################
# Generic prompt to handle numeric responses and evaluates the result.
# Arguments:
#   1
#   2
#######################################
prompt_numeric() {
  local prompt_message=$1
  local var_name=$2
  local input
  read -rp "$prompt_message" input
  while ! [[ $input =~ ^[0-9]+$ ]]; do
    echo "Please enter a valid number."
    read -rp "$prompt_message" input
  done
  eval "$var_name"="'$input'"
}

#######################################
# Prompts the user to select whether they want to use SSL.
# Globals:
#   AUTO_SETUP_CHOICE
#   SSL_CHOICE
# Arguments:
#  None
#######################################
prompt_for_ssl() {
  echo "1: Use Let's Encrypt SSL"
  echo "2: Use self-signed SSL certificates"
  echo "3: Do not enable SSL"
  prompt_numeric "Please enter your choice (1/2/3): " SSL_CHOICE
  case $SSL_CHOICE in
    1)
      set_ssl_flag
      echo "1: Run automatic staging setup for Let's Encrypt SSL (Recommended for testing)"
      echo "2: Run automatic production setup for Let's Encrypt SSL (Recommended for production)"
      echo "3: Run automatic reload of production setup for Let's Encrypt SSL (Keeps existing certificates and reloads server)"
      echo "4: Run custom setup for Let's Encrypt SSL (Advanced)"
      prompt_numeric "Please enter your choice (1/2/3/4): " AUTO_SETUP_CHOICE
      if [[ $AUTO_SETUP_CHOICE == 1 ]]; then
        set_letsencrypt_flag
        automatic_staging_selection
      elif [[ $AUTO_SETUP_CHOICE == 2 ]]; then
        set_letsencrypt_flag
        automation_production_selection
      elif [[ $AUTO_SETUP_CHOICE == 3 ]]; then
        set_letsencrypt_flag
        automatic_production_reload_selection
      elif [[ $AUTO_SETUP_CHOICE == 4 ]]; then
        set_letsencrypt_flag
        custom_install_prompt
      else
        echo "Invalid choice. Please enter 1, 2, 3, or 4."
      fi
      ;;
    2)
      set_self_signed_flag
      set_ssl_flag
      ;;
    3)
      echo "SSL will not be enabled."
      ;;
    *) echo "Invalid choice. Please enter 1, 2, or 3." ;;
  esac
}

#######################################
# Complex prompt that handles user input and evaluates the result - used for email addresses handling.
# Arguments:
#   1
#   2
#   3
#######################################
prompt_for_input() {
  local prompt_message="$1"
  local error_message="$2"
  local result_var="$3"
  local user_input
  while true; do
    read -rp "$prompt_message" user_input
    if [[ -n $user_input ]]; then
      eval "$result_var='$user_input'"
      break
    else
      echo "$error_message"
    fi
  done
}

#######################################
# Prompts the user to select whether they want to regenerate the SSL certificates/DH Parameters.
# Globals:
#   REGENERATE_SSL_CERTS
# Arguments:
#   1
# Returns:
#   0 ...
#   1 ...
#######################################
prompt_for_regeneration() {
  if [[ $REGENERATE_SSL_CERTS == "yes"  ]]; then
    return 0
  fi
  local response
  read -rp "Do you want to regenerate the certificates in $1? [y/N]: " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  else
    return 1
  fi
}

#######################################
# Prompts the user to select which DH Param strength they want to use.
# Globals:
#   DH_PARAM_CHOICE
#   DH_PARAM_SIZE
# Arguments:
#  None
#######################################
prompt_for_dhparam_strength() {
  echo "1: Use 2048-bit DH parameters (Faster)"
  echo "2: Use 4096-bit DH parameters (More secure)"
  prompt_numeric "Please enter your choice (1/2): " DH_PARAM_CHOICE
  case $DH_PARAM_CHOICE in
    1) DH_PARAM_SIZE=2048 ;;
    2) DH_PARAM_SIZE=4096 ;;
    *) echo "Invalid choice. Please enter 1 or 2." ;;
  esac
}

#######################################
# Prompts the user for the install mode.
# Globals:
#   INSTALL_MODE_CHOICE
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
prompt_for_install_mode() {
  echo "1: Install minimal release (frontend QR generation) (Limited features)"
  echo "2: Install full release (frontend QR generator and backend API/server side generation) (All features)"
  prompt_numeric "Please enter your choice (1/2): " INSTALL_MODE_CHOICE
  case $INSTALL_MODE_CHOICE in
    1) RELEASE_BRANCH="minimal-release" ;;
    2) RELEASE_BRANCH="full-release" ;;
    *) echo "Invalid choice. Please enter 1 or 2." ;;
  esac
}

#######################################
# Prompts the user to select whether they want to use a Google API key.
# Will enable Google Reviews QR Generation.
# Globals:
#   USE_GOOGLE_API_KEY
#   GOOGLE_API_KEY
# Arguments:
#  None
#######################################
prompt_for_google_api_key() {
  prompt_yes_no "Would you like to use a Google API key? (Will enable google reviews QR Generation)" USE_GOOGLE_API_KEY
  if [[ $USE_GOOGLE_API_KEY == "yes" ]]; then
    while true; do
      read -rp "Please enter your Google API key (or type 'skip' to skip): " GOOGLE_MAPS_API_KEY
      if [[ -n $GOOGLE_MAPS_API_KEY && $GOOGLE_MAPS_API_KEY != "skip" ]]; then
        break
      elif [[ $GOOGLE_MAPS_API_KEY == "skip" ]]; then
        echo "Google API key entry skipped."
        GOOGLE_MAPS_API_KEY=""  # Clear the variable if skipping
        break
      else
        echo "Error: Google API key cannot be empty. Type 'skip' to skip."
      fi
    done
  else
    echo "Google API key will not be used."
    GOOGLE_MAPS_API_KEY=""  # Clear the variable if not using Google API
  fi
}

#######################################
# Prompts for all domain information.
# Globals:
#   BACKEND_SCHEME
#   DOMAIN_NAME
#   ORIGIN
#   ORIGIN_PORT
#   SUBDOMAIN
#   USE_CUSTOM_DOMAIN
#   USE_SUBDOMAIN
# Arguments:
#  None
#######################################
prompt_for_domain_details() {
  prompt_yes_no "Would you like to specify a domain name other than the default (http://localhost)" USE_CUSTOM_DOMAIN
  if [[ $USE_CUSTOM_DOMAIN == "yes" ]]; then
    DOMAIN_NAME=$(prompt_with_validation "Enter your domain name (e.g., example.com): " "Error: Domain name cannot be empty.")
    local origin_url
    origin_url="$BACKEND_SCHEME://$DOMAIN_NAME"
    ORIGIN="$origin_url:$ORIGIN_PORT"
    echo "Using custom domain name: $origin_url"
    prompt_yes_no "Would you like to specify a subdomain other than the default (none)" USE_SUBDOMAIN
    if [[ $USE_SUBDOMAIN == "yes" ]]; then
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
# Prompts the user to select whether they want to use a custom domain and prompts for the relevant information.
# Globals:
#   USE_CUSTOM_DOMAIN
# Arguments:
#  None
#######################################
prompt_for_domain_and_letsencrypt() {
  prompt_for_domain_details
  if [[ $USE_CUSTOM_DOMAIN == "yes" ]]; then
    prompt_for_ssl
    construct_certbot_flags
  else
    prompt_for_self_signed_certificates
  fi
}

#######################################
#  Handles user input for their provided domain name/subdomain.
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
    if [[ -z $user_input ]]; then
      echo "$error_message"
    else
      echo "$user_input"
      break
    fi
  done
}
