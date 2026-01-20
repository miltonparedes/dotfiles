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
    function ta --description 'Attach to tmux session'
        if test (count $argv) -eq 0
            set -l sessions (tmux list-sessions -F '#{session_name}' 2>/dev/null)
            if test (count $sessions) -eq 0
                echo "No tmux sessions available"
                return 1
            else if test (count $sessions) -eq 1
                tmux attach-session -t $sessions[1]
            else
                echo "Available sessions:"
                tmux list-sessions
                echo ""
                echo "Attaching to: $sessions[1]"
                tmux attach-session -t $sessions[1]
            end
        else
            tmux attach-session -t $argv[1]
        end
    end
    function tad --description 'Attach to tmux session (detach others)'
        if test (count $argv) -eq 0
            set -l sessions (tmux list-sessions -F '#{session_name}' 2>/dev/null)
            if test (count $sessions) -eq 0
                echo "No tmux sessions available"
                return 1
            else if test (count $sessions) -eq 1
                tmux attach-session -d -t $sessions[1]
            else
                echo "Available sessions:"
                tmux list-sessions
                echo ""
                echo "Attaching to: $sessions[1] (detaching others)"
                tmux attach-session -d -t $sessions[1]
            end
        else
            tmux attach-session -d -t $argv[1]
        end
    end
    alias ts='tmux new-session -s'
    alias tl='tmux list-sessions'
    alias tksv='tmux kill-server'
    alias tkss='tmux kill-session -t'
    alias tmuxconf='nvim ~/.tmux.conf'

    # Quick session management
    # On Linux with systemd, sessions persist after SSH disconnect
    function tn --description 'New tmux session (named after directory or custom name)'
        set -l name
        if test (count $argv) -gt 0
            set name $argv[1]
        else
            set name (basename $PWD)
        end

        if set -q TMUX
            if not tmux has-session -t $name 2>/dev/null
                tmux new-session -d -s $name
            end
            tmux switch-client -t $name
        else if tmux has-session -t $name 2>/dev/null
            tmux attach-session -t $name
        else
            if test (uname) = Linux; and command -q systemd-run
                systemd-run --user --scope tmux new-session -s $name
            else
                tmux new-session -s $name
            end
        end
    end
    function tm --description 'New or attach to main tmux session'
        if set -q TMUX
            if not tmux has-session -t main 2>/dev/null
                tmux new-session -d -s main
            end
            tmux switch-client -t main
        else if tmux has-session -t main 2>/dev/null
            tmux attach-session -t main
        else
            # On Linux with systemd, use systemd-run to persist session after SSH disconnect
            if test (uname) = Linux; and command -q systemd-run
                systemd-run --user --scope tmux new-session -s main
            else
                tmux new-session -s main
            end
        end
    end
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