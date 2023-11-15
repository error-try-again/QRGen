#!/bin/bash

#######################################
# description
# Arguments:
#  None
#######################################
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"
  local opt
  select opt in "Run Setup" "Cleanup" "Reload/Refresh" "Dump logs" "Update Project" "Enable SSL with Let's Encrypt" "Stop Project Docker Containers" "Prune All Docker Builds - Dangerous" "Quit"; do
    case $opt in
      "Run Setup") setup ;;
      "Cleanup") cleanup ;;
      "Reload/Refresh") reload ;;
      "Dump logs") dump_logs ;;
      "Update Project") update_project ;;
      "Enable SSL with Let's Encrypt") enable_ssl ;;
      "Stop Project Docker Containers") stop_containers ;;
      "Prune All Docker Builds - Dangerous") purge_builds ;;
      "Quit") quit ;;
      *) echo "Invalid option. Try another one." ;;
    esac
    (($? == 0)) && break # Break the loop if the function executed successfully.
  done
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
    prompt_yes_no "Would you like to automatically renew your SSL certificate? (yes/no): " USE_AUTO_RENEW_SSL
    prompt_yes_no "Would you like to enable HSTS? (yes/no): " USE_HSTS
    prompt_yes_no "Would you like to enable OCSP Stapling? (yes/no): " USE_OCSP_STAPLING
    prompt_yes_no "Would you like to enable Must Staple? (yes/no): " USE_MUST_STAPLE
    prompt_yes_no "Would you like to enable Strict Permissions? (yes/no): " USE_STRICT_PERMISSIONS
    prompt_yes_no "Would you like to enable UIR (Unique Identifier for Revocation)? (yes/no): " USE_UIR
}

#######################################
# description
# Globals:
#   LETSENCRYPT_EMAIL
#   OVERWRITE_SELF_SIGNED_CERTS
#   REGENERATE_SSL_CERTS
#   USE_AUTO_RENEW_SSL
#   USE_DRY_RUN
#   USE_HSTS
#   USE_MUST_STAPLE
#   USE_OCSP_STAPLING
#   USE_PRODUCTION_SSL
#   USE_STRICT_PERMISSIONS
#   USE_UIR
# Arguments:
#  None
#######################################
# bashsupport disable=BP5006
automatic_selection() {
      LETSENCRYPT_EMAIL="skip"
      USE_AUTO_RENEW_SSL="yes"
      REGENERATE_SSL_CERTS="yes"
      USE_HSTS="yes"
      USE_OCSP_STAPLING="yes"
      USE_MUST_STAPLE="yes"
      USE_UIR="yes"
      USE_DRY_RUN="yes"
      OVERWRITE_SELF_SIGNED_CERTS="yes"
      USE_PRODUCTION_SSL="no"
      USE_STRICT_PERMISSIONS="no"
}

#######################################
# description
# Globals:
#   USE_AUTO_SETUP
#   USE_LETS_ENCRYPT
#   DOMAIN_NAME
# Arguments:
#  None
#######################################
prompt_for_ssl() {
  prompt_yes_no "Would you like to use Let's Encrypt SSL for $DOMAIN_NAME (yes/no)? " USE_LETS_ENCRYPT
  if [[ $USE_LETS_ENCRYPT == "yes"   ]]; then
    prompt_yes_no "Would you like to run auto-setup for Let's Encrypt SSL (yes/no)(Recommended)? " USE_AUTO_SETUP
    if [[ $USE_AUTO_SETUP == "yes"   ]]; then
      automatic_selection
    else
      custom_install_prompt
    fi
  fi
}

#######################################
# description
# Globals:
#   LETSENCRYPT_EMAIL
#   OVERWRITE_SELF_SIGNED_CERTS
#   USE_DRY_RUN
#   USE_HSTS
#   USE_MUST_STAPLE
#   USE_OCSP_STAPLING
#   USE_PRODUCTION_SSL
#   USE_STRICT_PERMISSIONS
#   USE_UIR
#   dry_run_flag
#   email_flag
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
  overwrite_self_signed_certs_flag=$([[ $OVERWRITE_SELF_SIGNED_CERTS == "yes"   ]] && echo "--overwrite-cert-dirs" || echo "")
  must_staple_flag=$([[ $USE_MUST_STAPLE == "yes"   ]] && echo "--must-staple" || echo "")
  ocsp_stapling_flag=$([[ $USE_OCSP_STAPLING == "yes"   ]] && echo "--staple-ocsp" || echo "")
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
