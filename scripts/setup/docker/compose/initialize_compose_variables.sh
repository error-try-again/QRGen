#!/usr/bin/env bash

set -euo pipefail

#######################################
# Initializes the variables used by the Docker Compose configuration.
# Globals:
#   backend_context
#   backend_depends_on
#   backend_dockerfile
#   backend_name
#   backend_networks
#   backend_restart
#   backend_volumes
#   certbot_context
#   certbot_depends_on
#   certbot_dockerfile
#   certbot_name
#   certbot_networks
#   certbot_volumes
#   frontend_context
#   frontend_depends_on
#   frontend_dockerfile
#   frontend_name
#   frontend_networks
#   frontend_restart
#   frontend_volumes
#   network_driver
#   network_name
#   volume_driver
#   volume_name
# Arguments:
#  None
#######################################
function initialize_variables() {
  export backend_service_definition=""
  export frontend_service_definition=""
  export certbot_service_definition=""

  export network_definition=""
  export volume_definition=""

  export backend_name="backend"
  export frontend_name="frontend"
  export certbot_name="certbot"

  export backend_context="."
  export frontend_context="."
  export certbot_context="."

  export backend_dockerfile="./backend/Dockerfile"
  export frontend_dockerfile="./frontend/Dockerfile"
  export certbot_dockerfile="./certbot/Dockerfile"

  local frontend_ports=""
  local backend_ports=""

  export backend_depends_on=""
  export frontend_depends_on="backend"
  export certbot_depends_on="frontend"

  export backend_restart="on-failure"
  export frontend_restart="on-failure"

  export backend_volumes=""
  export frontend_volumes=""
  export certbot_volumes=""

  export frontend_networks="qrgen"
  export backend_networks="qrgen"
  export certbot_networks="qrgen"

  export network_name="qrgen"
  export network_driver="bridge"

  export volume_name="nginx-shared-volume"
  export volume_driver="local"
}
