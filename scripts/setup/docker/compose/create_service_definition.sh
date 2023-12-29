#!/usr/bin/env bash

set -euo pipefail

#######################################
# Adds a ports, volumes or networks definition to the service definition.
# Globals:
#   ADDR
#   item
# Arguments:
#   1
#   2
#######################################
function add_to_definition() {
    local type=$1
    local values=$2
    if [[ -n ${values} ]]; then
      definition+=$'\n'
      definition+="    ${type}:"
      IFS=',' read -ra ADDR <<< "${values}"
      local item
      for item in "${ADDR[@]}"; do
        if [[ -n ${item} ]]; then
          definition+=$'\n'
          definition+="      - ${item}"
      fi
    done
  fi
}#######################################
# Created a generic service definition for Docker Compose file.
# Globals:
#   ADDR
# Arguments:
#  None
#######################################
function create_service_definition() {
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
  while [[ "$#" -gt 0 ]]; do
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
      *) shift ;;
    esac
  done

  # Building the service definition
  local definition
  definition="  ${name}:"
  definition+=$'\n'
  definition+="    build:"
  definition+=$'\n'
  definition+="      context: ${build_context}"
  definition+=$'\n'
  definition+="      dockerfile: ${dockerfile}"

  if [[ -n ${command} ]]; then
    definition+=$'\n'
    definition+="    command: ${command}"
  fi

  add_to_definition "ports" "${ports}"
  add_to_definition "volumes" "${volumes}"
  add_to_definition "networks" "${networks}"

  if [[ -n ${restart} ]]; then
    definition+=$'\n'
    definition+="    restart: ${restart}"
  fi

  if [[ -n ${depends} ]]; then
    add_to_definition "depends_on" "${depends}"
  fi

  echo "${definition}"
}
