#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Prompts the user to select whether they want to use a Google API key.
# Will enable Google Reviews QR Generation.
# Globals:
#   USE_GOOGLE_API_KEY
#   GOOGLE_API_KEY
# Arguments:
#  None
#######################################
function prompt_for_google_api_key() {
  if [[ ${USE_GOOGLE_API_KEY} == "true" ]]; then
    print_messages "Google API key already set. Skipping prompt."
    return
  fi
  prompt_yes_no "Would you like to use a Google API key? (Will enable google reviews QR Generation)" USE_GOOGLE_API_KEY
  if [[ ${USE_GOOGLE_API_KEY} == true ]]; then
    while true; do
      read -rp "Please enter your Google API key (or type 'skip' to skip): " GOOGLE_MAPS_API_KEY
      if [[ -n ${GOOGLE_MAPS_API_KEY} && ${GOOGLE_MAPS_API_KEY} != "skip" ]]; then
        # Proceed with provided API key
        break
      elif [[ ${GOOGLE_MAPS_API_KEY} == "skip" ]]; then
        # User chose to skip entering the API key
        print_messages "Google API key entry skipped."
        GOOGLE_MAPS_API_KEY="" # Clear the variable if skipping
        break
      else
        # The input was empty, and it's not a skip
        print_messages "Error: Google API key cannot be empty. Type 'skip' to skip."
      fi
    done
  else
    # User chose not to use a Google API key
    print_messages "Google API key will not be used."
    GOOGLE_MAPS_API_KEY="" # Ensure variable is empty
  fi
}
