# Workspace Navigation Setup

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
