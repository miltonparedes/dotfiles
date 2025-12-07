# Workspace Navigation Setup
# Load workspace aliases on shell startup

# Ensure z command is available (from zoxide)
if command -q zoxide
    # Setup workspace aliases
    setup_workspace_aliases
else
    echo "Warning: zoxide not found. Workspace aliases require zoxide to be installed."
end

# Quick navigation to common directories
alias work="z ~/Workspaces"
alias dots="z ~/Workspaces/M/dotfiles"
alias proj="z ~/Projects"
alias dl="z ~/Downloads"
alias docs="z ~/Documents"

# OS-specific workspace locations
if test (uname) = "Darwin"
    alias desktop="z ~/Desktop"
    alias icloud="z ~/Library/Mobile\ Documents/com~apple~CloudDocs"
else if test -f /etc/fedora-release
    alias desktop="z ~/Desktop"
end