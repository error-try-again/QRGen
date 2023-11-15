#!/bin/bash

#######################################
# description
# Globals:
#   PROJECT_LOGS_DIR
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
generate_certbot_renewal_job() {

  mkdir -p "${PROJECT_ROOT_DIR}/cron"
  local cron_script_path="${PROJECT_ROOT_DIR}/cron/certbot_renew.sh"

  # Create the certbot renew script with a heredoc
  cat << 'EOF' > "${cron_script_path}"
#!/bin/bash

# Exit on any error
set -e

# Load the environment variables
source "${PROJECT_ROOT_DIR}/.env" || { echo "Failed to load .env file"; exit 1; }

# Ensure the log directory exists
mkdir -p "${PROJECT_LOGS_DIR}" || { echo "Failed to create logs directory"; exit 1; }

LOG_FILE="${PROJECT_LOGS_DIR}/certbot_\$(date +'%Y%m%d_%H%M%S').log"

# Function to restart services with Docker Compose
restart_services() {
  local service_name="\$1"
  docker compose -f "\${compose_file}" up -d "\$service_name" && echo "Service \$service_name restarted successfully." || { echo "ERROR: Failed to restart the service \$service_name."; exit 1; }
}

# Function to perform a certbot renewal
renew_certbot() {
  # Run the certbot service with dry run first
  if docker compose run --rm certbot renew --dry-run; then
    echo "Certbot dry run succeeded, attempting renewal..."
    docker compose run --rm certbot renew
    restart_services "frontend"
    restart_services "backend"
  else
    echo "ERROR: Certbot dry run failed."
    exit 1
  fi
}

# Start logging
{
  echo "Running certbot renewal script on \$(date)"
  renew_certbot
} | tee -a "\${LOG_FILE}" # Append output to log file
EOF

  # Make the certbot renew script executable
  chmod +x "${cron_script_path}"

  # Setup Cron Job
  local cron_log_path="${PROJECT_LOGS_DIR}/certbot_cron.log"

  # Cron job to run certbot renewal every weekday at midnight (certbot limits to 5 renewals per week)
  local cron_job="0 0 * * 1-5 ${cron_script_path} >> ${cron_log_path} 2>&1"

  # Add the cron job if it doesn't exist
  (
    crontab -l 2> /dev/null | grep -Fv "${cron_script_path}"
    echo "$cron_job"
  ) | crontab -
}
