#!/usr/bin/env bash
#!/usr/bin/env bash
saved_stty=$(stty -g 2>/dev/null || true)

cleanup() {
  [ -n "$saved_stty" ] && stty "$saved_stty" 2>/dev/null || true
  tput reset 2>/dev/null || true
}

trap cleanup EXIT INT TERM

if [ -z "$GEMINI_API_KEY" ]; then
  secrets_file="$HOME/.config/fish/conf.d/secrets.fish"
  if [ -f "$secrets_file" ]; then
    GEMINI_API_KEY=$(awk -F'"' '/GEMINI_API_KEY/ {print $2; exit}' "$secrets_file")
  fi
fi

if [ -z "$GEMINI_API_KEY" ]; then
  echo "Gemini error: GEMINI_API_KEY is not set" >&2
  exit 1
fi

model=${GEMINI_MODEL:-gemini-3-flash-preview}

recent_commits=$(git log -n 6 --pretty=format:'%s')
diff_content=$(git diff --cached)

prompt_base="You are a Git commit message expert. Generate 3 concise commit messages.

RULES:
- Plain summary line only (no prefixes like feat:, no bullets, no quotes)
- Max 72 characters per message
- Use imperative mood (add, fix, update - not added, fixed, updated)
- Avoid trailing periods
- Match the style of recent commits below
- Each message should offer a different perspective on the changes

RECENT COMMITS (match this style):
$recent_commits

CHANGES TO ANALYZE:
$diff_content"

prompt_json="$prompt_base

OUTPUT FORMAT:
Return a JSON object with a \"commits\" array of exactly 3 strings"

prompt_text="$prompt_base

OUTPUT FORMAT:
Return exactly 3 lines, one message per line, no numbering"

payload_json=$(jq -n \
  --arg prompt "$prompt_json" \
  '{
    contents: [{ parts: [{ text: $prompt }] }],
    generationConfig: {
      responseMimeType: "application/json",
      responseSchema: {
        type: "object",
        properties: {
          commits: {
            type: "array",
            minItems: 3,
            maxItems: 3,
            items: { type: "string" }
          }
        },
        required: ["commits"]
      }
    }
  }')

payload_text=$(jq -n \
  --arg prompt "$prompt_text" \
  '{
    contents: [{ parts: [{ text: $prompt }] }],
    generationConfig: {
      responseMimeType: "text/plain"
    }
  }')

request() {
  curl -sS "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$1"
}

error_exit() {
  echo "Gemini error: $1" >&2
  exit 1
}

generate_from_text() {
  local response error_message text
  response=$(request "$payload_text")
  error_message=$(jq -r '.error.message? // empty' <<<"$response")
  if [ -n "$error_message" ]; then
    error_exit "$error_message"
  fi
  text=$(jq -r '.candidates[0].content.parts[0].text // empty' <<<"$response")
  if [ -z "$text" ] || [ "$text" = "null" ]; then
    error_exit "empty response"
  fi
  printf '%s\n' "$text" | awk 'NF { print; count++ } count==3 { exit }'
}

generate_from_json() {
  local response error_message commits_json commits
  response=$(request "$payload_json")
  error_message=$(jq -r '.error.message? // empty' <<<"$response")
  if [ -n "$error_message" ]; then
    return 1
  fi
  commits_json=$(jq -r '.candidates[0].content.parts[0].text // empty' <<<"$response")
  if [ -z "$commits_json" ] || [ "$commits_json" = "null" ]; then
    return 1
  fi
  commits=$(printf '%s\n' "$commits_json" | jq -r 'fromjson | .commits[]' 2>/dev/null)
  if [ -z "$commits" ]; then
    return 1
  fi
  printf '%s\n' "$commits"
}

commit_list=$(generate_from_json || generate_from_text)

printf '%s\n' "$commit_list" \
  | fzf --height 30% --border --ansi --preview "echo {}" --preview-window=up:wrap \
  | (read -r message && git commit --no-verify -m "$message")
