#!/usr/bin/env bash

set -euo pipefail

#######################################
# Adds a ports, volumes, or networks definition to the service definition.
# Arguments:
#   type: The type of definition being added (ports, volumes, or networks)
#   values: The comma-separated values to be added under the type
# Outputs:
#   Part of a service definition to be concatenated later.
#######################################
function add_to_definition() {
  local type=$1
  local values=$2
  local definition_part=""

  if [[ -n ${values} ]]; then
    definition_part+=$'\n'"    ${type}:"
    local items
    IFS=',' read -ra items <<<"${values}"
    local item
    for item in "${items[@]}"; do
      if [[ -n ${item} ]]; then
        definition_part+=$'\n'"      - ${item}"
      fi
    done
  fi
  echo "${definition_part}"
}

#######################################
# Creates a generic service definition for Docker Compose file.
# Arguments:
#   Named arguments for various parts of the service definition
# Outputs:
#   The service definition.
#######################################
function create_service_definition() {
shopt -s inherit_errexit

  local name=""
  local build_context=""
  local dockerfile=""
  local command=""
  local ports=""
  local volumes=""
  local networks=""
  local restart=""
  local depends=""

  # Parsing named arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --name)
      name=$2
      shift 2
      ;;
    --build-context)
      build_context=$2
      shift 2
      ;;
    --dockerfile)
      dockerfile=$2
      shift 2
      ;;
    --command)
      command=$2
      shift 2
      ;;
    --ports)
      ports=$2
      shift 2
      ;;
    --volumes)
      volumes=$2
      shift 2
      ;;
    --networks)
      networks=$2
      shift 2
      ;;
    --restart)
      restart=$2
      shift 2
      ;;
    --depends-on)
      depends=$2
      shift 2
      ;;
    *) # Unknown option
      echo "Warning: Ignored unknown option: $1"
      shift
      ;;
    esac
  done

  # Building the service definition
  local definition="  ${name}:"
  definition+=$'\n'"    build:"
  definition+=$'\n'"      context: ${build_context}"
  definition+=$'\n'"      dockerfile: ${dockerfile}"

  if [[ -n ${command} ]]; then
    definition+=$'\n'"    command: ${command}"
  fi

  definition+="$(add_to_definition "ports" "${ports}")"
  definition+="$(add_to_definition "volumes" "${volumes}")"
  definition+="$(add_to_definition "networks" "${networks}")"

  if [[ -n ${restart} ]]; then
    definition+=$'\n'"    restart: ${restart}"
  fi

  if [[ -n ${depends} ]]; then
    definition+="$(add_to_definition "depends_on" "${depends}")"
  fi

echo "${definition}"
}
