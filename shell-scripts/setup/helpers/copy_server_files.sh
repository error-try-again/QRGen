#!/bin/bash

# Initialize the Git repository if not already initialized
initialize_git_repository() {
    if [ ! -d "$PROJECT_ROOT_DIR/.git" ]; then
        echo "Initializing Git repository in $PROJECT_ROOT_DIR"
        git init "$PROJECT_ROOT_DIR"
  else
        echo "Git repository already initialized in $PROJECT_ROOT_DIR"
  fi
}

# Function to add or update a submodule
add_or_update_submodule() {
    local submodule_url="$1"
    local submodule_path="$2"

    if [ -d "$submodule_path" ] && [ ! -d "$submodule_path/.git" ]; then
        echo "Removing invalid submodule directory: $submodule_path"
        rm -rf "$submodule_path"
  fi

    if [ ! -d "$submodule_path/.git" ]; then
        echo "Adding the submodule: $submodule_path"
        git submodule add --force "$submodule_url" "$submodule_path"
  fi

    echo "Updating and initializing submodule: $submodule_path"
    git submodule update --init --recursive "$submodule_path"
}

#######################################
# Retrieves git submodules and copy the server files to the project root directory
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
# Returns:
#   1 on error
#######################################
retrieve_submodules() {

    echo "Navigating to the project root directory..."
    cd "$PROJECT_ROOT_DIR" || return 1

    local frontend_submodule_url="https://github.com/error-try-again/QRGen-frontend.git"
    local backend_submodule_url="https://github.com/error-try-again/QRGen-backend.git"
    local frontend_submodule_path="frontend"
    local backend_submodule_path="backend"

    add_or_update_submodule "$frontend_submodule_url" "$frontend_submodule_path"
    add_or_update_submodule "$backend_submodule_url" "$backend_submodule_path"

    local submodule_path
    for submodule_path in "$frontend_submodule_path" "$backend_submodule_path"; do
        echo "Navigating to the submodule: $submodule_path..."
        cd "$submodule_path" || return 1

        local branch_name="full-release"

        echo "Fetching latest information from the remote in submodule: $submodule_path..."
        git fetch --all

        echo "Hard resetting the submodule to the latest commit in the branch: $branch_name..."
        git reset --hard origin/full-release

        echo "Checking out branch '$branch_name' in submodule: $submodule_path..."
        if git rev-parse --verify "$branch_name" ; then
            git checkout "$branch_name"
    else
            echo "Branch '$branch_name' not found. Creating and checking out to the new branch..."
            git checkout -b "$branch_name" "origin/$branch_name"
    fi

        cd "$PROJECT_ROOT_DIR" || return 1
  done
}

copy_updated_dotenv() {
   cp ".env" "$BACKEND_DIR"
}

# Function to copy server files
copy_server_files() {
   copy_updated_dotenv
    if [ -z "$PROJECT_ROOT_DIR" ]; then
        echo "Error: PROJECT_ROOT_DIR is not set."
        return 1
  fi
    initialize_git_repository
    retrieve_submodules
}
