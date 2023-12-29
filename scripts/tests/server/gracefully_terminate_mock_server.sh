#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Gracefully terminate the mock server by checking if the process is still running using an error check
# Then send the TERM signal to allow graceful termination
# Then force kill if still running
# Globals:
#   MOCK_SERVER_PID
# Arguments:
#  None
#######################################
function gracefully_terminate_mock_server() {
  # Attempt to gracefully terminate the mock server
  if kill -0 "${MOCK_SERVER_PID}" &>/dev/null; then
    echo "---------------------------------------"
    echo "Terminating mock server with PID ${MOCK_SERVER_PID}"
    kill -15 "${MOCK_SERVER_PID}"                    # Send the TERM signal to allow graceful termination
    sleep 1                                          # Give it a moment to close
    kill -9 "${MOCK_SERVER_PID}" 2>/dev/null || true # Force kill if still running
  else
    echo "Mock server process ${MOCK_SERVER_PID} not found."
  fi
}
