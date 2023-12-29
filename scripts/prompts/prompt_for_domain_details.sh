#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
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
function prompt_for_domain_details() {
  if [[ ${SKIP_DOMAIN_PROMPT} == "true" ]]; then
     echo "Skipping domain prompt, please ensure that the following environment variables are set correctly:"
      echo "  BACKEND_SCHEME: ${BACKEND_SCHEME}"
      echo "  DOMAIN_NAME: ${DOMAIN_NAME}"
      echo "  ORIGIN: ${ORIGIN}"
      echo "  ORIGIN_PORT: ${ORIGIN_PORT}"
      echo "  SUBDOMAIN: ${SUBDOMAIN}"
      echo "  USE_CUSTOM_DOMAIN: ${USE_CUSTOM_DOMAIN}"
      echo "  USE_SUBDOMAIN: ${USE_SUBDOMAIN}"
    return
  fi
  prompt_yes_no "Would you like to specify a domain name other than the default (http://localhost)" USE_CUSTOM_DOMAIN
  if [[ ${USE_CUSTOM_DOMAIN} == true ]]; then
    DOMAIN_NAME=$(prompt_with_validation "Enter your domain name (e.g., example.com): " "Error: Domain name cannot be empty.")
    local origin_url="${BACKEND_SCHEME}://${DOMAIN_NAME}"
    ORIGIN="${origin_url}:${ORIGIN_PORT}"
    echo "Using custom domain name: ${origin_url}"

    prompt_yes_no "Would you like to specify a subdomain other than the default (none)" USE_SUBDOMAIN
    if [[ ${USE_SUBDOMAIN} == true ]]; then
      SUBDOMAIN=$(prompt_with_validation "Enter your subdomain name (e.g., www): " "Error: Subdomain name cannot be empty.")
      origin_url="${BACKEND_SCHEME}://${SUBDOMAIN}.${DOMAIN_NAME}"
      ORIGIN="${origin_url}:${ORIGIN_PORT}"
      echo "Using custom subdomain: ${origin_url}"
  fi
else
    DOMAIN_NAME="localhost"
    ORIGIN="${BACKEND_SCHEME}://${DOMAIN_NAME}:${ORIGIN_PORT}"
    echo "Using default domain name: ${ORIGIN}"
fi
}
