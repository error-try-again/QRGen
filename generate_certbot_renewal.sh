#!/bin/bash

# Ensure the .env file exists
if [ ! -f .env ]; then
  echo "The .env file does not exist, exiting..."
  exit 1
fi

# Source the .env file to define project environment variables
. .env

# Ensure the project root directory exists
mkdir -p "${PROJECT_ROOT_DIR}"

# Ensure the log directory exists
mkdir -p "${PROJECT_LOGS_DIR}"

# Create the certbot renew script with a heredoc
cat << 'EOF' > "${PROJECT_ROOT_DIR}/certbot_renew.sh"
#!/bin/bash

# Load the environment variables
. "${PROJECT_ROOT_DIR}/.env"

# Check if the docker environment script exists before sourcing
if [ -f "${PROJECT_ROOT_DIR}/shell-scripts/docker/test-docker-env.sh" ]; then
  . "${PROJECT_ROOT_DIR}/shell-scripts/docker/test-docker-env.sh"
else
  echo "Docker environment script not found, exiting..."
  exit 1
fi

LOG_FILE="${PROJECT_LOGS_DIR}/certbot_\$(date +'%Y%m%d_%H%M%S').log"

# Ensure the log directory exists
mkdir -p "${PROJECT_LOGS_DIR}"

# Enter the project root directory, exit if it fails
cd "${PROJECT_ROOT_DIR}" || exit 1

# Test the Docker environment, exit if it fails
test_docker_env || exit 1

# Start logging
{
  echo "Running certbot renewal script on \$(date)"

  # Run the certbot service with dry run first and check if it succeeds
  if docker compose run --rm certbot renew --dry-run; then
    # If the dry run succeeds, run certbot renewal without dry run
    echo "Certbot dry run succeeded, attempting renewal..."
    docker compose run --rm certbot renew
  else
    echo "Certbot dry run failed, skipping renewal."
    exit 1
  fi
} | tee -a "${LOG_FILE}" # Append output to log file
EOF

# Make the certbot renew script executable
chmod +x "${PROJECT_ROOT_DIR}/certbot_renew.sh"

# The path to the cron job script
cron_script_path="${PROJECT_ROOT_DIR}/certbot_renew.sh"
cron_log_path="${PROJECT_LOGS_DIR}/certbot_cron.log"

# The crontab entry to be added
cron_job="0 0 * * * ${cron_script_path} >> ${cron_log_path} 2>&1"

# Check and add the cron job if it doesn't exist
if ! crontab -l | grep -Fxq "$cron_job"; then
  (
    crontab -l 2> /dev/null
    echo "$cron_job"
  ) | crontab -
fi
