#!/usr/bin/env bash
# Helper: shows preview for the sessionizer
# - Session target → capture of active pane in that session
# - Window target (session:index) → capture of that window's pane

item="$1"

if [[ "$item" == *:* ]]; then
  tmux capture-pane -ep -t "$item" 2>/dev/null
else
  # Show the active pane of the session
  tmux capture-pane -ep -t "$item" 2>/dev/null
fi
