#!/usr/bin/env python

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Remote
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔎
# @raycast.argument1 { "type": "text", "placeholder": "project path" }
# @raycast.argument2 { "type": "text", "placeholder": "editor (cursor, zed or vscode)", "optional": true }
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.author miltonparedes
# @raycast.authorURL https://raycast.com/miltonparedes

import os
import subprocess
import sys

from dotenv import load_dotenv
from thefuzz import process

# Load environment variables from ../../.env
dotenv_path = os.path.join(os.path.dirname(__file__), "..", "..", ".env")
load_dotenv(dotenv_path)

remote_host = os.getenv("REMOTE_HOST")
remote_user = os.getenv("REMOTE_USER")
remote_workspace = os.getenv("REMOTE_WORKSPACE")


def run_ssh_command(command):
    """Execute an SSH command and return the output."""
    ssh_command = ["ssh", f"{remote_user}@{remote_host}", command]
    try:
        result = subprocess.run(
            ssh_command,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def path_exists(remote_path):
    """Check if the remote directory exists."""
    command = f'test -d "{remote_path}" && echo "Exists" || echo "Not exists"'
    result = run_ssh_command(command)
    return result == "Exists"


def list_projects():
    """List all projects within the remote workspace."""
    command = f'find "{remote_workspace}" -mindepth 2 -maxdepth 2 -type d'
    result = run_ssh_command(command)
    if result:
        # Extract relative paths of the projects
        projects = [
            line.replace(f"{remote_workspace}/", "") for line in result.split("\n")
        ]
        return projects
    return []


def find_similar_project(provided_path, available_projects, threshold=59):
    """Find the most similar project based on string similarity using thefuzz."""
    match = process.extractOne(provided_path, available_projects)
    if match and match[1] >= threshold:
        return match[0]
    return None


def main():
    if len(sys.argv) < 2:
        print("No project path provided.")
        sys.exit(1)

    project_path = sys.argv[1].strip("/")

    editor = sys.argv[2] if len(sys.argv) >= 3 and sys.argv[2] else "cursor"

    remote_path = os.path.join(remote_workspace, project_path)

    if not path_exists(remote_path):
        print(f"Project path '{project_path}' does not exist on {remote_host}.")

        available_projects = list_projects()
        if not available_projects:
            print(f"No projects found in {remote_workspace}.")
            sys.exit(1)

        similar_project = find_similar_project(
            project_path, available_projects, threshold=50
        )

        if similar_project:
            print(f"Did you mean '{similar_project}'? Using the closest match.")
            project_path = similar_project
            remote_path = os.path.join(remote_workspace, project_path)
        else:
            print("No similar project found.")
            sys.exit(1)

    folder_uri = f"vscode-remote://ssh-remote+{remote_host}{remote_path}"

    if editor in ("code", "vscode"):
        command = ["code", "--folder-uri", folder_uri]
    elif editor == "cursor":
        command = ["cursor", "--folder-uri", folder_uri]
    elif editor == "zed":
        # TODO: Add real support for zed
        command = ["zed", "--folder-uri", folder_uri]
    else:
        print(f"Unsupported editor: {editor}")
        sys.exit(1)

    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error opening {project_path} with {editor} on {remote_host}: {e}")
        sys.exit(1)

    print(f"Opening {project_path} with {editor} on {remote_host}")


if __name__ == "__main__":
    main()
