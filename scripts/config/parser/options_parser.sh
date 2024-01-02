#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

########################################
# Parse the script options using getopt.
# Support both short and long options, defining behavior for known flags.
# Use 'getopt' to parse the provided options and set up an options processing loop.
# Arguments:
#   None
# Returns:
#   None
#######################################
function options_parser() {

  local long_options_list

  # Define long options for the script. Each option is followed by a comma.
  # Options requiring an argument are followed by a colon.
  long_options_list="setup,mock,uninstall,dump-logs,update-project,help,quit,stop-containers,purge"

  # Parse the provided options using getopt. This prepares them for consumption.
  # -o defines short options, here only 'h' (help) as a short option.
  # -n defines the name of the script for error messages.
  # --long defines the long options.
  # The last -- "$@" passes all the script's command-line arguments for parsing.
  local parsed_options
  parsed_options=$(getopt -o h -n 'script.bash' --long "${long_options_list}" -- "$@")

  # Exit if getopt has encountered an error.
  if [[ -z ${parsed_options} ]]; then
    print_messages "Failed parsing options." >&2
    exit 1
  fi

  eval set -- "${parsed_options}"
  while true; do
    case "$1" in
      --help | -h)
        # Display help message and terminate script execution.
        display_help
        ;;
      --setup)
        # Perform setup and terminate script execution.
        setup
        ;;
      --mock)
        # Perform mock function and terminate script execution.
        mock
        ;;
      --uninstall)
        # Perform uninstall function and terminate script execution.
        uninstall
        ;;
      --stop-containers)
        # Stop containers and terminate script execution.
        stop_containers
        ;;
      --purge)
        # Perform purge function and terminate script execution.
        purge
        ;;
      --dump-logs)
        # Dump logs and terminate script execution.
        dump_logs
        ;;
      --update-project)
        # Update project and terminate script execution.
        update_project
        ;;
      --quit)
        # Terminate script execution.
        quit
        ;;
      --)
        # End of options.
        break
        ;;
      *)
        # Unexpected option.
        print_messages "Unexpected option: $1" >&2
        quit
        ;;
  esac
    # Proceed to next option if available.
    shift
done
}
