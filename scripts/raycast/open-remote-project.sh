#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Remote Project
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔎
# @raycast.argument1 { "type": "text", "placeholder": "project path" }
# @raycast.argument2 { "type": "text", "placeholder": "editor (cursor, zed or vscode)", "optional": true }
# @raycast.argument3 { "type": "text", "placeholder": "remote host", "optional": true }
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.author miltonparedes
# @raycast.authorURL https://raycast.com/miltonparedes

source "$(dirname "$0")/../../.env"

get_ssh_host() {
    local input_host="$1"
    local default_host="box"

    # If no host provided, return default
    if [ -z "$input_host" ]; then
        echo "$default_host"
        return
    fi

    local hosts=$(grep "^Host " ~/.ssh/config | awk '{print $2}')

    # Try fuzzy match using fzf
    local matched_host=$(echo "$hosts" | fzf --filter="$input_host" --no-sort | head -n1)

    if [ -n "$matched_host" ]; then
        echo "$matched_host"
    else
        echo "$default_host"
    fi
}

run_ssh_command() {
    local host=$(get_ssh_host "${REMOTE_HOST}")
    ssh "${REMOTE_USER}@${host}" "$1"
}

list_projects_and_check_path() {
    local literal_path="$1"
    local check_path="$2"
    run_ssh_command "
        projects=\$(find \"${REMOTE_WORKSPACE}\" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*' | sed \"s|${REMOTE_WORKSPACE}/||\")
        echo \"\$projects\"
        # Check literal path first
        if [ -d \"${REMOTE_WORKSPACE}/${literal_path}\" ]; then
            echo \"LITERAL_PATH_EXISTS\"
        elif [ -d \"${REMOTE_WORKSPACE}/${check_path}\" ]; then
            echo \"PATH_EXISTS\"
        else
            echo \"PATH_NOT_EXISTS\"
        fi
    "
}

if [ $# -lt 1 ]; then
    echo "No project path provided."
    exit 1
fi

project_path="${1%/}"
editor="${2:-zed}"
remote_host="${3}"

if [ -n "$remote_host" ]; then
    REMOTE_HOST=$(get_ssh_host "$remote_host")
fi

project_root=$(echo "$project_path" | cut -d'/' -f1,2)

output=$(list_projects_and_check_path "$project_path" "$project_root")
projects=$(echo "$output" | sed '$d')
path_exists=$(echo "$output" | tail -n1)

# Check if literal path exists first
if [ "$path_exists" = "LITERAL_PATH_EXISTS" ]; then
    echo "Opening literal path: $project_path"
    final_path="$project_path"
elif [ "$path_exists" = "PATH_EXISTS" ]; then
    # Project root exists, use it
    final_path="$project_root"
else
    # Neither literal nor project root exists, try fuzzy matching
    echo "Path '$project_path' does not exist on $REMOTE_HOST."

    similar_project=$(echo "$projects" | fzf --filter="$project_root" --no-sort | head -n1)

    if [ -n "$similar_project" ]; then
        echo "Did you mean '$similar_project'? Using the closest match."
        final_path="$similar_project"
    else
        echo "No similar project found."
        exit 1
    fi
fi

remote_path="${REMOTE_WORKSPACE}/${final_path}"
folder_uri="vscode-remote://ssh-remote+${REMOTE_HOST}${remote_path}"

case "$editor" in
    code|vscode)
        command="code-insiders --folder-uri \"$folder_uri\""
        ;;
    cursor)
        command="cursor --folder-uri \"$folder_uri\""
        ;;
    zed)
        zed_uri="ssh://${REMOTE_USER}@${REMOTE_HOST}${remote_path}"
        command="zed \"$zed_uri\""
        ;;
    *)
        echo "Unsupported editor: $editor"
        exit 1
        ;;
esac

if eval "$command"; then
    echo "Opening $final_path with $editor on $REMOTE_HOST"
else
    echo "Error opening $final_path with $editor on $REMOTE_HOST"
    exit 1
fi
