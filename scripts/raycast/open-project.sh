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

if [ $# -lt 1 ]; then
    echo "No project path provided."
    exit 1
fi

project_path="${1%/}"
editor="${2:-zed}"

project_root=$(find "${LOCAL_WORKSPACE}" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*' | \
    sed "s|${LOCAL_WORKSPACE}/||" | \
    fzf --filter="$project_path" --no-sort | \
    head -n1)

if [ -z "$project_root" ]; then
    echo "No project found matching '$project_path'"
    exit 1
fi

local_path="${LOCAL_WORKSPACE}/${project_root}"

if [ ! -d "$local_path" ]; then
    echo "Project path '$project_root' does not exist locally."
    exit 1
fi

case "$editor" in
    code|vscode)
        command="code-insiders \"$local_path\""
        ;;
    cursor)
        command="cursor \"$local_path\""
        ;;
    zed)
        command="zed \"$local_path\""
        ;;
    *)
        echo "Editor no soportado: $editor"
        exit 1
        ;;
esac

if eval "$command"; then
    echo "Opening $project_root with $editor"
else
    echo "Error opening $project_root with $editor"
    exit 1
fi
