#!/bin/bash

initialize_cert_watcher() {

  # Configuration through environment variables or a default value
  WATCHED_DIR="${WATCHED_DIR:-certs/live/$DOMAIN_NAME}"
  COMPOSE_FILE="${COMPOSE_FILE:-$PROJECT_ROOT_DIR/docker-compose.yml}"
  CHECKSUM_FILE="${CHECKSUM_FILE:-$PROJECT_ROOT_DIR/certs/cert_checksum}"
  LOG_FILE="$PROJECT_LOGS_DIR/cert-watcher.log"

  # Validate required configuration
  validate_configuration() {
    local vars=(DOMAIN_NAME PROJECT_ROOT_DIR PROJECT_LOGS_DIR)
    for var in "${vars[@]}"; do
      if [ -z "${!var}" ]; then
        echo "Configuration error: $var is not set."
        exit 1
      fi
    done
  }

  # Check if necessary commands are available
  check_dependencies() {
    local dependencies=(inotifywait sha256sum awk)
    for cmd in "${dependencies[@]}"; do
      if ! command -v "$cmd" &>/dev/null; then
        echo "Command $cmd could not be found. Please install it."
        exit 1
      fi
    done
  }

  log_message() {
    local message="$1"
    local datetime
    datetime=$(date '+%Y-%m-%d %H:%M:%S')

    # Check if the log directory is writable
    if [[ ! -w "$PROJECT_LOGS_DIR" ]]; then
      echo "ERROR: Log directory $PROJECT_LOGS_DIR is not writable. Attempting to log to /tmp instead."
      LOG_FILE="/tmp/cert-watcher.log"
    fi

    # Check if the log file is writable or can be created
    if [[ ! -w "$LOG_FILE" ]] && ! touch "$LOG_FILE" 2>/dev/null; then
      echo "ERROR: Log file $LOG_FILE is not writable and cannot be created. Logging to console."
      echo "$datetime - $message"
      return 1
    fi

    # Write the log message to the log file
    echo "$datetime - $message" >>"$LOG_FILE"

    # Implement log rotation
    local max_size=10240 # for example, 10 MB
    local filesize
    filesize=$(stat -c "%s" "$LOG_FILE" 2>/dev/null || echo "0")
    if [[ $filesize -gt $max_size ]]; then
      mv "$LOG_FILE" "$LOG_FILE.$(date '+%Y%m%d%H%M%S')"
      touch "$LOG_FILE"
    fi
  }

  # Get the checksum of the certificate
  get_certificate_checksum() {
    sha256sum "$WATCHED_DIR/fullchain.pem" | awk '{print $1}'
  }

  # Store the checksum to a file
  store_checksum() {
    local checksum="$1"
    echo "$checksum" >"$CHECKSUM_FILE"
  }

  # Read the stored checksum from a file
  read_stored_checksum() {
    if [[ -f "$CHECKSUM_FILE" ]]; then
      cat "$CHECKSUM_FILE"
    else
      echo ""
    fi
  }

  # Check for the actual certificate update by comparing checksums
  certificate_updated() {
    local last_checksum
    last_checksum=$(read_stored_checksum)
    local new_checksum
    new_checksum=$(get_certificate_checksum)

    if [[ "$new_checksum" != "$last_checksum" ]]; then
      log_message "Certificate checksum has changed from $last_checksum to $new_checksum."
      store_checksum "$new_checksum"
      return 0 # True, certificate has changed
    else
      log_message "Certificate checksum is still $last_checksum."
      return 1 # False, certificate has not changed
    fi
  }

  # Restart services with Docker Compose
  restart_services() {
    local service_name="$1"
    if docker compose -f "$COMPOSE_FILE" up -d "$service_name"; then
      log_message "Service $service_name restarted successfully."
    else
      log_message "ERROR: Failed to restart the service $service_name."
      exit 1
    fi
  }

  # Function to check and kill any existing watcher processes
  check_and_kill_existing_watchers() {
    local inotify_command='inotifywait -m -e close_write --format %w%f certs/live/qr-gen.net/fullchain.pem'

    # Check if the inotifywait process is running and kill it
    if pkill -f "$inotify_command"; then
      echo "Existing cert watcher process found and stopped successfully."
    else
      echo "No existing cert watcher process found or unable to stop it."
    fi

    # Adding a small delay to allow the process to terminate
    sleep 2
  }

  monitor_certificates() {
    # Watch only the fullchain.pem file for close_write events
    local watched_file="$WATCHED_DIR/fullchain.pem"

    # Use setsid to run in a new session, this makes it the leader of a new process group
    setsid inotifywait -m -e close_write --format '%w%f' "$watched_file" | while read -r filepath; do
      log_message "Detected change to $(basename "$filepath"), verifying update..."
      if certificate_updated; then
        log_message "Certificate update confirmed, restarting services..."
        restart_services "certbot"
      else
        log_message "No update to certificate detected."
      fi
    done &
  }

  # Initial operations
  validate_configuration
  check_dependencies
  store_checksum "$(get_certificate_checksum)"
  check_and_kill_existing_watchers

  # Start monitoring in the background
  monitor_certificates
}
