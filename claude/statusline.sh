#!/bin/bash
# Claude Code Status Line
# Receives JSON via stdin with: model, workspace, context_window, cost, etc.

input=$(cat)

# === Workspace (using wt, folder name only) ===
wt_info=$(wt list statusline --claude-code 2>/dev/null | sed 's|https\?://[^ ]*||g; s|/[^ ]*/||; s/\x1b\[0m /\x1b[0m/; s/  */ /g' | tr -d '\n' || echo "workspace")

# === Model ===
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# === Context Window ===
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
usage=$(echo "$input" | jq '.context_window.current_usage')

if [ "$usage" != "null" ] && [ -n "$usage" ]; then
    # Includes input + output + cache tokens for context usage
    current_tokens=$(echo "$usage" | jq '.input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    pct=$((current_tokens * 100 / context_size))
else
    pct=0
fi

# === Output ===
printf "%s | %s | ctx: %d%%" "$wt_info" "$model" "$pct"
