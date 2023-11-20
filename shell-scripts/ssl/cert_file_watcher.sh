#!/bin/bash

initialize_cert_watcher() {
  # Configuration through environment variables or a default value
  watched_dir="${WATCHED_DIR:-certs/live/$DOMAIN_NAME}"
  checksum_file="${CHECKSUM_FILE:-$PROJECT_ROOT_DIR/certs/cert_checksum}"
  log_file="$PROJECT_LOGS_DIR/cert-watcher.log"

  # Validate required configuration
  validate_configuration() {
    local vars=(DOMAIN_NAME PROJECT_ROOT_DIR PROJECT_LOGS_DIR)
    local var
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
    local cmd
    for cmd in "${dependencies[@]}"; do
      if ! command -v "$cmd" &> /dev/null; then
        echo "Command $cmd could not be found. Please install it."
        exit 1
      fi
    done
  }

  #######################################
  # description
  # Globals:
  #   log_file
  #   PROJECT_LOGS_DIR
  # Arguments:
  #   1
  # Returns:
  #   1 ...
  #######################################
  log_message() {
    local message="$1"
    local datetime
    datetime=$(date '+%Y-%m-%d %H:%M:%S')

    # Check if the log directory is writable
    if [[ ! -w $PROJECT_LOGS_DIR   ]]; then
      echo "ERROR: Log directory $PROJECT_LOGS_DIR is not writable. Attempting to log to /tmp instead."
      log_file="/tmp/cert-watcher.log"
    fi

    # Check if the log file is writable or can be created
    if [[ ! -w $log_file   ]] && ! touch "$log_file" 2> /dev/null; then
      echo "ERROR: Log file $log_file is not writable and cannot be created. Logging to console."
      echo "$datetime - $message"
      return 1
    fi

    # Write the log message to the log file
    echo "$datetime - $message" >> "$log_file"

    # Implement log rotation
    local max_size=10240 # for example, 10 MB
    local filesize
    filesize=$(stat -c "%s" "$log_file" 2> /dev/null || echo "0")
    if [[ $filesize -gt $max_size ]]; then
      mv "$log_file" "$log_file.$(date '+%Y%m%d%H%M%S')"
      touch "$log_file"
    fi
  }

  # Get the checksum of the certificate
  get_certificate_checksum() {
    sha256sum "$watched_dir/fullchain.pem" | awk '{print $1}'
  }

  # Store the checksum to a file
  store_checksum() {
    local checksum="$1"
    echo "$checksum" > "$checksum_file"
  }

  # Read the stored checksum from a file
  read_stored_checksum() {
    if [[ -f $checksum_file   ]]; then
      cat "$checksum_file"
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

    if [[ $new_checksum != "$last_checksum"   ]]; then
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
    echo "Restarting backend and frontend services..."
    if ! docker compose restart backend || ! docker compose restart frontend; then
        echo "Failed to restart services."
        return 1
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

  #######################################
  # description
  # Globals:
  #   watched_dir
  #   filepath
  # Arguments:
  #  None
  #######################################
  monitor_certificates() {
    # Watch only the fullchain.pem file for close_write events
    local watched_file="$watched_dir/fullchain.pem"

    # Use setsid to run in a new session, this makes it the leader of a new process group
    setsid inotifywait -m -e close_write --format '%w%f' "$watched_file" | while read -r filepath; do
      log_message "Detected change to $(basename "$filepath"), verifying update..."
      if certificate_updated; then
        log_message "Certificate update confirmed, restarting services..."
        restart_services
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
