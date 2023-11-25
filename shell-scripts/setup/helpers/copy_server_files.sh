#!/bin/bash


#######################################
# Retrieves git submodules and copy the server files to the project root directory
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
retrieve_submodules() {
    # Check if PROJECT_ROOT_DIR is set
    if [ -z "$PROJECT_ROOT_DIR" ]; then
        echo "Error: PROJECT_ROOT_DIR is not set."
        return 1 # Exit the function with an error status
    fi

    echo "Navigating to the project root directory..."
    cd "$PROJECT_ROOT_DIR" || return 1 # Exit if the directory change fails

    # Define the frontend submodule URL and path
    local frontend_submodule_url="https://github.com/error-try-again/QRGen-frontend.git"
    local frontend_submodule_path="frontend"

    # Check if the frontend submodule already exists
    if [ ! -d "$frontend_submodule_path" ]; then

        # If the frontend submodule doesn't exist, check if the current directory is a git repository
        if [ ! -d ".git" ]; then
            echo "Initializing the git repository..."
            git init
        fi

        echo "Adding the frontend submodule..."
        git submodule add --force "$frontend_submodule_url" "$frontend_submodule_path"
    else
        echo "Frontend submodule already exists. Updating..."
        git submodule update --init --recursive "$frontend_submodule_path"
    fi

    echo "Navigating to the frontend submodule..."
    cd "$frontend_submodule_path" || return 1 # Exit if the directory change fails

    # Create a new branch if it doesn't already exist
    local branch_name="origin/minimal-release"

    if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        echo "Branch '$branch_name' already exists. Checking out the branch..."
        git checkout "$branch_name"
    else
        echo "Creating and checking out to the new branch '$branch_name'..."
        git checkout -b "$branch_name"
    fi

    echo "Current directory content:"
    ls -la
}
