#!/bin/bash

# Check if the given port is a valid number and not in use.
is_port_in_use() {
  local port="$1"
  # Check if the port is a number.
  if ! [[ $port =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be a number."
    return 2 # Return a different exit code for invalid input.
  fi

  # Check if the port is in use. Using netcat (nc) as it is more commonly available.
  if nc -z 127.0.0.1 "$port" > /dev/null 2>&1; then
    return 0  # Port is in use
  else
    return 1  # Port is not in use
  fi
}

ensure_port_available() {
  local port="$1"
  local default_port=8080 # Define a default port, if necessary

  # Check if the port is in use, and prompt for a new one if it is.
  while is_port_in_use "$port"; do
    local input_port
    echo "Port $port is already in use."
    read -rp "Please provide an alternate port or Ctrl+C to exit: " input_port

    # Use the provided port or default to the previously set default_port if no input is given
    port="${input_port:-$default_port}"
  done

  # Set the nginx_port to the selected port that is not in use.
  nginx_port="$port"
  echo "Selected port $nginx_port is available."
}
