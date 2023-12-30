#!/usr/bin/env bash

set -euo pipefail

#######################################
# Set command flags to their default false state
# Globals:
#   dump_logs
#   purge
#   quit
#   mock
#   setup
#   stop_containers
#   uninstall
#   update_project
#######################################
function initialize_command_flags() {
  setup=false
  mock=false
  uninstall=false
  dump_logs=false
  update_project=false
  stop_containers=false
  purge=false
  quit=false
}
