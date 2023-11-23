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

LOG_FILE="${PROJECT_LOGS_DIR}/certbot_renew.log"

# Function to perform a certbot renewal
renew_certbot() {
  # Run the certbot service with dry run first
  docker compose run --rm certbot renew --dry-run

  # If the dry run succeeds, run certbot renewal without dry run
  echo "Certbot dry run succeeded, attempting renewal..."
  docker compose run --rm certbot renew

  # Restart the nginx frontend services
  docker compose restart frontend
}

# Start logging
{
  echo "Running certbot renewal script on $(date)"
  renew_certbot
} | tee -a "${LOG_FILE}"
EOF

  # Make the certbot renew script executable
  chmod +x "${PROJECT_ROOT_DIR}/certbot_renew.sh"

  # Setup Cron Job
  local cron_script_path="${PROJECT_ROOT_DIR}/certbot_renew.sh"
  local cron_log_path="${PROJECT_LOGS_DIR}/certbot_cron.log"

  # Cron job to run certbot renewal every day at midnight
  local cron_job="0 0 * * 1-7 ${cron_script_path} >> ${cron_log_path} 2>&1"

  # Check if the cron job already exists
  if ! crontab -l | grep -Fq "$cron_job"; then
    # Add the cron job if it doesn't exist
    (
      crontab -l 2> /dev/null
                               echo "$cron_job"
    )                                             | crontab -
    echo "Cron job added."
  else
    echo "Cron job already exists. No action taken."
  fi
}
