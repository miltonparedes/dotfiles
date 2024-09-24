#!/bin/bash

# Function to create aliases for repositories
create_repo_aliases() {
    local base_dir="$1"
    local company_letter="$2"

    if [[ ! -d "$base_dir" ]]; then
        return
    }

    # Associative array to keep track of used aliases
    declare -A used_aliases

    for dir in "$base_dir"/*; do
        if [[ -d "$dir" ]]; then
            local repo_name=$(basename "$dir")
            local first_letter=${repo_name:0:1}
            local alias_name="z${company_letter}${first_letter}"

            # If the alias is already used, try the second letter
            if [[ ${used_aliases[$alias_name]} ]]; then
                alias_name="z${company_letter}${repo_name:0:2}"
            fi

            # If still conflicting, skip this repo
            if [[ ${used_aliases[$alias_name]} ]]; then
                echo "Warning: Conflicting alias for $repo_name, skipping."
                continue
            fi

            alias "$alias_name"="z $dir"
            used_aliases[$alias_name]=1
        fi
    done
}

# Create aliases for company projects
create_repo_aliases "$HOME/Workspaces/Company" "c"

# Create aliases for third-party projects
create_repo_aliases "$HOME/Workspaces/Thirdparty" "t"

# Function to list all created aliases
list_repo_aliases() {
    alias | grep "^z[ct]"
}

# Create an alias to list all repo aliases
alias lsrepo="list_repo_aliases"

# Ensure the 'z' command is available
if ! command -v z &> /dev/null; then
    echo "Warning: 'z' command not found. Please install 'z' or replace it with 'cd' in this script."
fi
