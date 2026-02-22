#!/bin/sh
# Detect if current tmux session is accessed via SSH
# Sets @is-remote user option for conditional status bar formatting

if tmux show-environment SSH_CONNECTION 2>/dev/null | grep -q '^SSH_CONNECTION='; then
    tmux set -g @is-remote 1
else
    tmux set -g @is-remote 0
fi
