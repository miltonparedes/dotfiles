#!/usr/bin/env bash
# Helper: shows preview for the sessionizer
# - Session target → capture of active pane in that session
# - Window target (session:index) → capture of that window's pane

item="$1"

if [[ "$item" == __group__:* ]]; then
  # Virtual group header: show summary of all sessions in this group
  prefix="${item#__group__:}"
  printf "\033[1m%s\033[0m (group)\n\n" "$prefix"
  while IFS=' ' read -r sess_name windows attached; do
    [[ "$sess_name" == "$prefix"-* || "$sess_name" == "$prefix" ]] || continue
    tag=""
    [ "$attached" = "1" ] && tag=" (attached)"
    printf "  \033[36m%s\033[0m  %sw%s\n" "$sess_name" "$windows" "$tag"
  done < <(tmux list-sessions -F '#{session_name} #{session_windows} #{?session_attached,1,0}' | sort)
elif [[ "$item" == *:* ]]; then
  tmux capture-pane -ep -t "$item" 2>/dev/null
else
  # Show the active pane of the session
  tmux capture-pane -ep -t "$item" 2>/dev/null
fi
