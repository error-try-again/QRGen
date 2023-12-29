#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
# Globals:
#   common_configuration
#   test_output_dir
# Arguments:
#   1
#   2
#######################################
function validate_service_config() {
  local file=$1
  local type=$2

  local command log_file
  log_file="${test_output_dir}/validation_${file##*/}.log"

  case ${type} in
  nginx)
    command="nginx -t -c ${file}"
    assert_nginx_has_port "${file}"
    ;;
  docker)
    command="docker compose -f ${file} config"
    assert_compose_has_port "${file}"
    ;;
  *)
    echo "Invalid configuration type: ${type}" >&2
    exit 1
    ;;
  esac

  echo "---------------------------------------"
  echo "Validating ${type} configuration: ${file}"
  if ! ${command} &>"${log_file}"; then
    log_mock_error "Validation failed for ${type} with configuration file ${file}"
    echo "Complete log can be found at ${log_file}"
  else
    echo "Validation successful for ${type} with configuration file ${file}"
  fi
}
