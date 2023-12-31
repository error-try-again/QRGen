#!/usr/bin/env bash
# bashsupport disable=BP2001,BP5006

set -euo pipefail

#######################################
# Check if the given port is a valid number and not in use.
# Arguments:
#   1
# Returns:
#   0 ...
#   1 ...
#   2 ...
#######################################
function is_port_in_use() {
	local port="$1"
	# Check if the port is a number.
	if ! [[ ${port} =~ ^[0-9]+$ ]]; then
		print_messages "Error: Port must be a number."
		return 2 # Return a different exit code for invalid input.
	fi

	# Check if the port is in use. Using netcat (nc) as it is more commonly available.
	if nc -z 127.0.0.1 "${port}" >/dev/null 2>&1; then
		return 0 # Port is in use
	else
		return 1 # Port is not in use
	fi
}

#######################################
# Prompt for a port and ensure it is available.
# Globals:
#   EXPOSED_NGINX_PORT
# Arguments:
#   1
#######################################
function ensure_port_is_available() {
  local port="$1"
  local auto_increment_port="$2"
  # Check if the port is in use, auto increment if it is and the flag is "true".
  while "is_port_in_use" "${port}"; do
    if [[ ${auto_increment_port} == "auto" ]]; then
      ((port++))
    else
      local alternate_port
      print_messages "Port ${port} is already in use."
      read -rp "Please provide an alternate port or Ctrl+C to exit: " alternate_port
      port="${alternate_port:-${port}}"
    fi
  done
  # Set the EXPOSED_NGINX_PORT to the selected port that is not in use.
  EXPOSED_NGINX_PORT="${port}"
  print_messages "Selected port ${EXPOSED_NGINX_PORT} is available."
}
