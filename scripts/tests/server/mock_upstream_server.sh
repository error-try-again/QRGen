#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Checks if the designated port is in use and offers to kill the process using it.
# Globals:
#   PORT
# Outputs:
#   Prompts the user for action if the port is in use.
#######################################
function check_port_and_kill_process_if_needed() {
  PORT=12345
  SLEEP_DURATION=1

  local process_ids
  process_ids=$(lsof -Pi :"${PORT}" -sTCP:LISTEN -t || true)

  if [[ -n "${process_ids}" ]]; then
    echo "Port ${PORT} is in use. Found the following processes:"
    local pid
    for pid in ${process_ids}; do
      if [[ "${pid}" =~ ^[0-9]+$ ]]; then
        local process_name
        process_name=$(ps -p "${pid}" -o comm=)
        echo "PID: ${pid} - Process Name: ${process_name}"

        echo "Would you like to kill it? (y/n):" >&2
        local response
        read -n 1 -r response
        echo >&2 # move to a new line

        if [[ ${response} =~ ^[Yy]$ ]]; then
          kill -9 "${pid}" && echo "Process ${pid} (${process_name}) has been killed."
        else
          echo "Process ${pid} not killed."
        fi
      else
        echo "Error: Found non-numeric process ID '${pid}' for port ${PORT}." >&2
      fi
    done
  else
    echo "Port ${PORT} is available."
  fi
}

#######################################
# Starts a mock server on a designated port.
# Globals:
#   PORT
#   MOCK_SERVER_PID
#   SLEEP_DURATION
# Outputs:
#   Information about the mock server's status.
#######################################
function start_mock_server() {
  nc -lk -p "${PORT}" &
  MOCK_SERVER_PID=$!
  echo "Mock server has been started with PID: ${MOCK_SERVER_PID}" >&2
  sleep "${SLEEP_DURATION}"
}

#######################################
# Validates whether the mock server has started successfully.
# Globals:
#   MOCK_SERVER_PID
# Outputs:
#   Error message if the server failed to start.
#######################################
function validate_server_start() {
  if ! kill -0 "${MOCK_SERVER_PID}" 2>/dev/null; then
    echo "Starting the mock server failed. Check connectivity or port availability." >&2
    exit 1
  fi
}

#######################################
# Orchestrates the setup of a mock upstream server.
# Calls functions to check port availability, start the server, and validate the start.
#######################################
function mock_upstream_server() {
  check_port_and_kill_process_if_needed
  start_mock_server
  validate_server_start
}
