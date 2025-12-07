# TMUX Configuration for Fish Shell

# Auto-start TMUX on SSH sessions (optional)
# Uncomment the following lines if you want TMUX to start automatically on SSH
# if status is-interactive
#     and set -q SSH_CLIENT
#     and not set -q TMUX
#     tmux new-session -A -s main
# end

# TMUX aliases
if command -q tmux
    alias ta='tmux attach -t'
    alias tad='tmux attach -d -t'
    alias ts='tmux new-session -s'
    alias tl='tmux list-sessions'
    alias tksv='tmux kill-server'
    alias tkss='tmux kill-session -t'
    alias tmuxconf='nvim ~/.tmux.conf'
    
    # Quick session management
    alias tn='tmux new -s (basename $PWD)'
    alias tm='tmux new -s main'
end

# Function to create or attach to project-specific tmux session
function tmux-project --description 'Create or attach to a project-specific tmux session'
    set -l session_name (basename $PWD | sed 's/\./-/g')
    
    if tmux has-session -t $session_name 2>/dev/null
        echo "Attaching to existing session: $session_name"
        tmux attach-session -t $session_name
    else
        echo "Creating new session: $session_name"
        tmux new-session -s $session_name
    end
end

# Alias for the function
alias tp='tmux-project'