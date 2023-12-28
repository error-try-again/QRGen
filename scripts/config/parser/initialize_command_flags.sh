#!/usr/bin/env bash

set -euo pipefail

#######################################
# Set command flags to their default false state
# Globals:
#   dump_logs
#   prune_builds
#   quit
#   run_mocks
#   setup
#   stop_containers
#   uninstall
#   update_project
#######################################
function initialize_command_flags() {
  setup=false
  run_mocks=false
  uninstall=false
  dump_logs=false
  update_project=false
  stop_containers=false
  prune_builds=false
  quit=false
}
