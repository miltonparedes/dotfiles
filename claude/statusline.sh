#!/bin/bash
# Claude Code Status Line
# Receives JSON via stdin with: model, workspace, context_window, cost, etc.

input=$(cat)

# === Workspace (using wt, folder name only) ===
wt_info=$(wt list statusline --claude-code 2>/dev/null | sed 's|https\?://[^ ]*||g; s|/[^ ]*/||; s/\x1b\[0m /\x1b[0m/; s/  */ /g' | tr -d '\n' || echo "workspace")

# === Model (short name only) ===
full_model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
case "$full_model" in
    *Opus*)   model="Opus" ;;
    *Sonnet*) model="Sonnet" ;;
    *Haiku*)  model="Haiku" ;;
    *)        model="$full_model" ;;
esac

# === Context Window ===
# Context usage = tokens being SENT to Claude (not output tokens being generated now)
# Output tokens from previous responses are already included in input as conversation history
# Cache file to avoid 0% -> N% jumps between messages
CACHE_FILE="/tmp/claude_statusline_ctx_${USER:-claude}"
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000' 2>/dev/null)
usage=$(echo "$input" | jq '.context_window.current_usage' 2>/dev/null)

pct=0
if [ "$usage" != "null" ] && [ -n "$usage" ]; then
    # Formula: input_tokens + cache tokens (no output_tokens - those are being generated, not sent)
    current_tokens=$(echo "$usage" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' 2>/dev/null)

    if [ -n "$current_tokens" ] && [ "$current_tokens" -gt 0 ] 2>/dev/null; then
        pct=$((current_tokens * 100 / context_size))
        (( pct < 0 )) && pct=0
        (( pct > 100 )) && pct=100
        # Cache valid percentage
        echo "$pct" > "$CACHE_FILE" 2>/dev/null
    fi
fi

# Use cached value if current is 0 (data not yet available)
if [ "$pct" -eq 0 ] && [ -f "$CACHE_FILE" ]; then
    cached=$(cat "$CACHE_FILE" 2>/dev/null)
    [ -n "$cached" ] && [ "$cached" -gt 0 ] 2>/dev/null && pct=$cached
fi

# === Output ===
printf "%s | %s | ⛁ %d%%" "$wt_info" "$model" "$pct"
