#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Assigns a value to a flag in the global scope.
# If an optional value is not supplied, defaults to true.
# Arguments:
#   1: flag name
#   2: optional value for flag
#######################################
assign_flag_value() {
  local flag_name="${1//--/}" # Strip leading double-dash
  flag_name="${flag_name//-/_}" # Convert hyphens to underscores
  local flag_value="${2:-true}" # Default to true if no value provided

  # Validate that flag_name is expected
  if ! [[ $flag_name =~ ^(use_|no_)?[a-z_]+$ ]]; then
    echo "Error: Unexpected flag '$flag_name'"
    exit 1
  fi

  declare -g "$flag_name"="$flag_value"
}

#######################################
# Parse script options
# Allows the script to accept both short and long options.
# Arguments:
#  None
#######################################
parse_options() {

  local long_options_list
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

  local parsed_options
  parsed_options=$(getopt -o h -n 'script.bash' --long "$long_options_list" -- "$@")

  if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
  fi

  eval set -- "$parsed_options"

  while true; do
    case "$1" in
      --help | -h)
        echo "Usage instructions for the script..."
        exit 0
        ;;
      --) shift; break ;;
      *)  # No more options, so break out of the loop.
          if [[ "$2" =~ ^-.* || -z "$2" ]]; then
            assign_flag_value "$1"
          else
            assign_flag_value "$1" "$2"
            shift
          fi
          ;;
    esac
    shift
  done
}
