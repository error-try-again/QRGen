#!/usr/bin/env bash

set -euo pipefail

#######################################
# Function to handle ambiguous Docker networks
# Arguments:
#  None
#######################################
function handle_ambiguous_networks() {
  print_messages "Searching for ambiguous Docker networks..."
  local networks_ids
  local network_id

  # Get all custom networks (excluding default ones)
  networks_ids=$(docker network ls --filter name=qrgen --format '{{.ID}}')

  # Loop over each network ID
  for network_id in ${networks_ids}; do
    print_messages "Inspecting network ${network_id} for connected containers..."
    local container_ids
    local container_id
    container_ids=$(docker network inspect "${network_id}" --format '{{range .Containers}}{{.Name}} {{end}}')

    # Loop over each container ID connected to the network and disconnect it
    for container_id in ${container_ids}; do
      print_messages "Disconnecting container ${container_id} from network ${network_id}..."
      docker network disconnect -f "${network_id}" "${container_id}" || {
        print_messages "Failed to disconnect container ${container_id} from network ${network_id}"
      }
    done

    # Remove the network
    print_messages "Removing network ${network_id}..."
    docker network rm "${network_id}" || {
      print_messages "Failed to remove network ${network_id}"
    }
  done
}
