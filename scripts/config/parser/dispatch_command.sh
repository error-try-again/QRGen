#!/usr/bin/env bash
# bashsupport disable=BP2001,BP5006

set -euo pipefail

#######################################
# Dispatches the user provided command or runs TUI if no command flags are provided
# Globals:
#   BASH_SOURCE
#   dump_logs
#   purge
#   quit
#   mock
#   setup
#   stop_containers
#   uninstall
#   update_project
# Arguments:
#  None
#######################################
function dispatch_command() {
  trap quit SIGINT
  options_parser "$@"

  # Associative array to map the command flag to the corresponding function to execute.
  local -A command_function_map=(
                ["${setup}"]=setup
                ["${mock}"]=mock
                ["${uninstall}"]=uninstall
                ["${dump_logs}"]=dump_logs
                ["${update_project}"]=update_project
                ["${stop_containers}"]=stop_containers
                ["${purge}"]=purge
                ["${quit}"]=quit
                ["${help}"]=display_help
)
  local command_executed=false
  local command

  # Iterate over the keys of the associative array and check if the key is true
  # If the key is true, then execute the corresponding function and set command_executed to true
  # If no command is executed, then run the user prompt
  for command in "${!command_function_map[@]}"; do
    if [[ ${command} == true ]]; then
      eval "${command_function_map[${command}]}"
      command_executed=true
      break
    fi
  done
  if [[ ${command_executed} == false ]]; then
    prompt_user
  fi
}
