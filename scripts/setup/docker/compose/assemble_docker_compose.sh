#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Assembles the final Docker Compose configuration file.
# This function consolidates all configurations and service definitions
# into a single Docker Compose YAML file, which is then written to disk.
#######################################
function assemble_docker_compose_configuration() {
  backend_service_definition=$(create_service_definition \
    --name "${backend_name}" \
    --build-context "${backend_context}" \
    --dockerfile "${backend_dockerfile}" \
    --ports "${express_ports}" \
    --volumes "${express_volumes}" \
    --networks "${backend_networks}" \
    --restart "${backend_restart}" \
    --depends-on "${backend_depends_on}")

  frontend_service_definition=$(create_service_definition \
    --name "${frontend_name}" \
    --build-context "${frontend_context}" \
    --dockerfile "${frontend_dockerfile}" \
    --ports "${frontend_ports}" \
    --volumes "${frontend_volumes}" \
    --networks "${frontend_networks}" \
    --restart "${frontend_restart}" \
    --depends-on "${frontend_depends_on}")

  network_definition=$(create_network_definition \
    "${network_name}" \
    "${network_driver}")

  volume_definition=$(create_volume_definition \
    "${volume_name}" \
    "${volume_driver}")

  {
    echo "version: '3.8'"
    echo "services:"
    echo "${backend_service_definition}"
    echo "${frontend_service_definition}"
    echo "${certbot_service_definition}"
    echo "${network_definition}"
    echo "${volume_definition}"
  } > "${DOCKER_COMPOSE_FILE}"

  print_messages "Docker Compose configuration written to ${DOCKER_COMPOSE_FILE}"
}
