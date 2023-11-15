#!/bin/bash

#######################################
# description
# Globals:
#   PROJECT_LOGS_DIR
#   PROJECT_ROOT_DIR
#   cron_job
#   cron_log_path
#   cron_script_path
# Arguments:
#  None
#######################################
generate_certbot_renewal_job() {

  # Create the certbot renew script with a heredoc
  cat << 'EOF' > "${PROJECT_ROOT_DIR}/certbot_renew.sh"
#!/bin/bash

# Exit on any error
set -e

# Load the environment variables
. "${PROJECT_ROOT_DIR}/.env"

# Ensure the log directory exists
mkdir -p "${PROJECT_LOGS_DIR}"

LOG_FILE="${PROJECT_LOGS_DIR}/certbot_\$(date +'%Y%m%d_%H%M%S').log"

# Function to restart services with Docker Compose
restart_services() {
  local service_name="$1"
  if docker compose -f "$compose_file" up -d "$service_name"; then
    echo "Service $service_name restarted successfully."
  else
    echo "ERROR: Failed to restart the service $service_name."
    exit 1
  fi
}

# Function to perform a certbot renewal
renew_certbot() {
  # Run the certbot service with dry run first
  docker compose run --rm certbot renew --dry-run

  # If the dry run succeeds, run certbot renewal without dry run
  echo "Certbot dry run succeeded, attempting renewal..."
  docker compose run --rm certbot renew

  # Restart the nginx frontend and backend services
  restart_services "frontend"
  restart_services "backend"
}

# Start logging
{
  echo "Running certbot renewal script on \$(date)"

  renew_certbot
} | tee -a "${LOG_FILE}" # Append output to log file
EOF

  # Make the certbot renew script executable
  chmod +x "${PROJECT_ROOT_DIR}/certbot_renew.sh"

  # Setup Cron Job
  local cron_script_path="${PROJECT_ROOT_DIR}/certbot_renew.sh"
  local cron_log_path="${PROJECT_LOGS_DIR}/certbot_cron.log"

  # Cron job to run certbot renewal every weekday at midnight (certbot limits to 5 renewals per week)
  local cron_job="0 0 * * 1-5 ${cron_script_path} >> ${cron_log_path} 2>&1"

  # Add the cron job if it doesn't exist
  (
    crontab -l 2> /dev/null
                          echo "$cron_job"
  ) | crontab -

}
