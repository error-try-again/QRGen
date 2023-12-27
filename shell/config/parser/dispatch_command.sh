#!/usr/bin/env bash
# bashsupport disable=BP2001,BP5006

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
initialize_command_flags() {
  setup=false
  run_mocks=false
  uninstall=false
  dump_logs=false
  update_project=false
  stop_containers=false
  prune_builds=false
  quit=false
}

#######################################
# Dispatches the user provided command or runs TUI if no command flags are provided
# Globals:
#   BASH_SOURCE
#   dump_logs
#   prune_builds
#   quit
#   run_mocks
#   setup
#   stop_containers
#   uninstall
#   update_project
# Arguments:
#  None
#######################################
dispatch_command() {
  trap quit SIGINT
  parse_options "$@"

  local -A command_function_map=(
                     ["$setup"]=setup
                     ["$run_mocks"]=run_mocks
                     ["$uninstall"]=uninstall
                     ["$dump_logs"]=dump_logs
                     ["$update_project"]=update_project
                     ["$stop_containers"]=stop_containers
                     ["$prune_builds"]=purge_builds
                     ["$quit"]=quit
  )

  local command_executed=false
  local command

  for command in "${!command_function_map[@]}"; do
    if [ "$command" = true ]; then
      PROMPT_BYPASS=true
      eval "${command_function_map[$command]}"
      command_executed=true
      break
    fi
  done
  if [ "$command_executed" = false ]; then
    PROMPT_BYPASS=false
    user_prompt
  fi
}
