#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Remote Project
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔎
# @raycast.argument1 { "type": "text", "placeholder": "project path" }
# @raycast.argument2 { "type": "text", "placeholder": "editor (cursor, zed or vscode)", "optional": true }
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.author miltonparedes
# @raycast.authorURL https://raycast.com/miltonparedes

source "$(dirname "$0")/../../.env"

run_ssh_command() {
    ssh "${REMOTE_USER}@${REMOTE_HOST}" "$1"
}

list_projects_and_check_path() {
    local check_path="$1"
    run_ssh_command "
        projects=\$(find \"${REMOTE_WORKSPACE}\" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*' | sed \"s|${REMOTE_WORKSPACE}/||\")
        echo \"\$projects\"
        if [ -d \"${REMOTE_WORKSPACE}/${check_path}\" ]; then
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
editor="${2:-cursor}"

project_root=$(echo "$project_path" | cut -d'/' -f1,2)

output=$(list_projects_and_check_path "$project_root")
projects=$(echo "$output" | sed '$d')
path_exists=$(echo "$output" | tail -n1)

if [ "$path_exists" = "PATH_NOT_EXISTS" ]; then
    echo "Project path '$project_root' does not exist on $REMOTE_HOST."

    similar_project=$(echo "$projects" | fzf --filter="$project_root" --no-sort | head -n1)

    if [ -n "$similar_project" ]; then
        echo "Did you mean '$similar_project'? Using the closest match."
        project_root="$similar_project"
    else
        echo "No similar project found."
        exit 1
    fi
fi

remote_path="${REMOTE_WORKSPACE}/${project_root}"
folder_uri="vscode-remote://ssh-remote+${REMOTE_HOST}${remote_path}"

case "$editor" in
    code|vscode)
        command="code --folder-uri \"$folder_uri\""
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
    echo "Opening $project_root with $editor on $REMOTE_HOST"
else
    echo "Error opening $project_root with $editor on $REMOTE_HOST"
    exit 1
fi
