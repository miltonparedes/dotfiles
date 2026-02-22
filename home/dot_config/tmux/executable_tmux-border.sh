#!/bin/sh
# Generate a horizontal line of box-drawing characters for tmux status bar
# Uses tmux's client width to determine the number of characters

width=$(tmux display-message -p '#{client_width}' 2>/dev/null)

# Fallback to 80 if we can't get the width
[ -z "$width" ] || [ "$width" -eq 0 ] && width=80

# Print the line - use printf in a loop (tr doesn't handle multibyte chars in GNU)
printf '─%.0s' $(seq 1 "$width")
