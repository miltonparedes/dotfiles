#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Local Project
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

list_projects_and_check_path() {
    local check_path="$1"
    projects=$(find "${LOCAL_WORKSPACE}" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*' | sed "s|${LOCAL_WORKSPACE}/||")
    echo "$projects"
    if [ -d "${LOCAL_WORKSPACE}/${check_path}" ]; then
        echo "PATH_EXISTS"
    else
        echo "PATH_NOT_EXISTS"
    fi
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
    echo "Project path '$project_root' does not exist locally."

    similar_project=$(echo "$projects" | fzf --filter="$project_root" --no-sort | head -n1)

    if [ -n "$similar_project" ]; then
        echo "Did you mean '$similar_project'? Using the closest match."
        project_root="$similar_project"
    else
        echo "No similar project found."
        exit 1
    fi
fi

local_path="${LOCAL_WORKSPACE}/${project_root}"

case "$editor" in
    code|vscode)
        command="code \"$local_path\""
        ;;
    cursor)
        command="cursor \"$local_path\""
        ;;
    zed)
        command="zed \"$local_path\""
        ;;
    *)
        echo "Unsupported editor: $editor"
        exit 1
        ;;
esac

if eval "$command"; then
    echo "Opening $project_root with $editor locally"
else
    echo "Error opening $project_root with $editor"
    exit 1
fi
