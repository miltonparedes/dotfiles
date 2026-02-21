#!/usr/bin/env bash
# tmux session/window navigator with fzf
# Two-level tree: Sessions → Windows
# Sessions are grouped by project (worktrees shown indented)
#
# Keybindings:
#   →/tab  drill into session's windows
#   ←      back to sessions
#   enter  switch to selection

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

selected=$(
  "$SCRIPT_DIR/tmux-sessionizer-list.sh" sessions |
    fzf \
        --reverse \
        --height=100% \
        --no-sort \
        --ansi \
        --cycle \
        --with-nth=$'{2..}\033[2m {1}\033[0m' \
        --prompt='Sessions › ' \
        --header='→ expand  ← back  enter switch  alt+N jump' \
        --bind='alt-1:pos(1)+accept' \
        --bind='alt-2:pos(2)+accept' \
        --bind='alt-3:pos(3)+accept' \
        --bind='alt-4:pos(4)+accept' \
        --bind='alt-5:pos(5)+accept' \
        --bind='alt-6:pos(6)+accept' \
        --bind='alt-7:pos(7)+accept' \
        --bind='alt-8:pos(8)+accept' \
        --bind='alt-9:pos(9)+accept' \
        --border=none \
        --bind="right:reload($SCRIPT_DIR/tmux-sessionizer-list.sh windows {1})+change-prompt(Windows › )+first" \
        --bind="tab:reload($SCRIPT_DIR/tmux-sessionizer-list.sh windows {1})+change-prompt(Windows › )+first" \
        --bind="left:reload($SCRIPT_DIR/tmux-sessionizer-list.sh sessions)+change-prompt(Sessions › )+first"
)

[ -z "$selected" ] && exit 0

target=$(echo "$selected" | awk '{print $1}')

tmux switch-client -t "$target"
