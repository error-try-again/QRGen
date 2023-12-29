#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Setup development configuration parameters
# Globals:
#   USE_LETSENCRYPT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
function setup_dev_mock_parameters() {
  USE_LETSENCRYPT=false
  USE_SELF_SIGNED_CERTS=false
  DOCKER_COMPOSE_FILE="${test_output_dir}/docker-compose-ss.yml"
  BACKEND_DOCKERFILE="${test_output_dir}/Backend.Dockerfile"
}
