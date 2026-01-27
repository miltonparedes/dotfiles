# Workspace Navigation Setup
# Load workspace aliases on shell startup

# Ensure zoxide is available before setting up workspace navigation
if not command -q zoxide
    # Silent fail - zoxide may not be installed on all systems
    return
end

# Setup workspace aliases
setup_workspace_aliases

# Quick navigation to common directories
alias work="z ~/Workspaces"
alias dots="z dotfiles"
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
