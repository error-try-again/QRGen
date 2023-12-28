#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# This function assigns a value to a global flag variable.
# It strips leading double-dashes and replaces hyphens with underscores in the flag name.
# If no value is provided for the flag, it defaults to true.
# Arguments:
#   1: flag name (string) - the name of the flag variable to assign.
#   2: optional value for flag (string) - the value to assign to the flag variable; defaults to 'true'.
# Exits:
#   1 - If the flag name does not match expected pattern.
#######################################
assign_flag_value() {
  # Transform flag name to adhere to variable naming conventions:
  # Strip leading double-dash and replace hyphens with underscores.
  local flag_name="${1//--/}" # Strip leading double-dash
  flag_name="${flag_name//-/_}" # Replace hyphens with underscores
  local flag_value="${2:-true}" # Default flag value to 'true' if no value provided

  # Validate that flag_name adheres to expected naming conventions:
  # Starts with 'use_' or 'no_', followed by lowercase letters or underscores.
  if ! [[ $flag_name =~ ^(use_|no_)?[a-z_]+$ ]]; then
    echo "Error: Unexpected flag '$flag_name'"
    exit 1
  fi

  # Declare a global variable dynamically using the name and value provided.
  declare -g "$flag_name"="$flag_value"
}

#######################################
# This function parses the script options using getopt.
# It supports both short and long options, defining behavior for known flags.
# Uses 'getopt' to parse the provided options and sets up an options processing loop.
# Arguments:
#   None
# Exits:
#   1 - If options parsing fails.
#######################################
options_parser() {

  local long_options_list

  # Define long options for the script. Each option is followed by a comma.
  # Options requiring an argument are followed by a colon.
  long_options_list="setup,run-mocks,uninstall,dump-logs,update-project,\
stop-containers,prune-builds,quit,use-hsts,use-ocsp-stapling,use-tls13,\
use-tls12,backend-port:,nginx-port:,nginx-ssl-port:,challenge-port:,\
node-version:,dns-resolver:,timeout:,domain-name:,backend-scheme:,\
subdomain:,regenerate-ssl-certs:,letsencrypt-email:,use-production-ssl:,\
use-lets-encrypt:,use-custom-domain:,use-must-staple:,use-strict-permissions:,\
use-uir:,use-dry-run:,use-auto-renew-ssl:,use-overwrite-self-signed-certs:,\
use-force-renew:,use-self-signed-certs:,use-ssl:,dh-param-size:,tos-flag:,\
no-eff-email-flag:,non-interactive-flag:,rsa-key-size:,build-certbot-image:,\
disable-docker-caching:,use-google-api-key:,google-maps-api-key:,\
release-branch:,use-gzip:,help"

  # Parse the provided options using getopt. This prepares them for consumption.
  # -o defines short options, here only 'h' (help) as a short option.
  # -n defines the name of the script for error messages.
  # --long defines the long options.
  # The last -- "$@" passes all the script's command-line arguments for parsing.
  local parsed_options
  parsed_options=$(getopt -o h -n 'script.bash' --long "$long_options_list" -- "$@")

  # Exit if getopt has encountered an error.
  if [[ -z $parsed_options ]]; then
    echo "Failed parsing options." >&2
    exit 1
  fi

  # Evaluate the parsed options string to set the positional parameters ($1, $2, etc.)
  eval set -- "$parsed_options"

  while true; do
    case "$1" in
      --help | -h)
        echo "Usage instructions for the script..."
        exit 0
        ;;
      --) # End of all options.
          shift
          break
          ;;
      *)
           # Default case: handle long option or its argument.
          # If the second parameter looks like another option or if it's empty, consider it a boolean flag.
          # Otherwise, treat it as an argument for an option.
          if [[ "$2" =~ ^-.* || -z "$2" ]]; then
            assign_flag_value "$1"
      else
            assign_flag_value "$1" "$2"
            shift # Move past the argument as it's been handled.
      fi
          ;;
  esac
      shift # Move to the next parameter or option.
done
}
