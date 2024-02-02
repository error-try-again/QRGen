#!/usr/bin/env bash
# shellcheck disable=SC2034

set -euo pipefail

#######################################
# Displays all profiles from the JSON config file
# and prompts the user to choose one to be applied.
# Globals:
#   output
#   profile
# Arguments:
#   json_file: The JSON file name.
#######################################
select_and_apply_profile() {
  local json_file=$1

  validate_json_file "${json_file}"
  print_messages "Available profiles:"

  # Read profiles into an array
  local profiles
  output=$(jq -r 'keys | .[]' "${json_file}")
  readarray -t profiles <<< "${output}"

  # For each profile, print an index and the profile name to the console (starting at 1)
  local index=1
  local profile
  for profile in "${profiles[@]}"; do
    echo "${index}) ${profile}"
    ((index++))
  done

  # Validate selection and apply profile
  while true; do
    # Prompt the user to choose a profile
    local selection
    read -rp "Select a profile to apply [1-${#profiles[@]}]: " selection
    # Sanity check the selection is a number and within the range of the array length
    if [[ ${selection} =~ ^[0-9]+$ ]] && [[ ${selection} -ge 1 ]] && [[ ${selection} -le ${#profiles[@]} ]]; then
      local selected_profile=${profiles[selection - 1]}
      print_messages "You selected: ${selected_profile}"
      apply_profile "${json_file}" "${selected_profile}"
      break
    else
      print_messages "Invalid selection: ${selection}"
    fi
  done
}
