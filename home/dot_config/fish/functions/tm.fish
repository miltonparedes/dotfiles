function tm --description 'Start or attach to persistent tmux session'
    if command tmux has-session 2>/dev/null
        command tmux attach $argv
    else if command -q systemd-run
        # Linux: use systemd-run to survive terminal close
        systemd-run --scope --user command tmux new-session $argv
    else
        # macOS: regular tmux
        command tmux new-session $argv
    end
end
