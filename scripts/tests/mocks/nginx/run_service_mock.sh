#!/usr/bin/env bash
# bashsupport disable=BP5006

#######################################
# Mocks a service for testing
# Global variable:
#   test_output_dir - The directory where the output of the tests will be stored
# Arguments:
#   1 - service_stack : The stack of the service to be tested.
#   2 - service_variant : The variant of the service to be tested.
#   3 - config_file_name : The name of the configuration file used for the service.
function run_service_mock() {
	local service_stack=$1
	local service_variant=$2
	local config_file_name=$3
	local operational_log
	local separator
	local conf_file_path
	local message

	conf_file_path="${test_output_dir}/${service_stack}/${service_variant}/${config_file_name}"
	operational_log="${test_output_dir}/${service_stack}/${service_variant}/ops_log_$(report_timestamp).log"

	mkdir -p "${test_output_dir}/${service_stack}/${service_variant}"

	message="Building config - [${service_stack}] - [${service_variant}]"
	print_messages "${message}"

generate_configuration_file "${service_stack}" "${service_variant}" "${conf_file_path}" "${operational_log}"
}
