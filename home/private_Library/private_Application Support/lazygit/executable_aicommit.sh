#!/usr/bin/env bash
set -euo pipefail

diff_content=$(git diff --cached)
if [ -z "$diff_content" ]; then
  echo "No staged changes" >&2
  exit 1
fi

recent_commits=$(git log -n 6 --pretty=format:'%s' 2>/dev/null || true)

prompt="Generate exactly 3 commit messages, one per line, no numbering, no bullets, no quotes.
Each message should offer a different perspective on the changes.

RECENT COMMITS (match this style):
${recent_commits}

CHANGES:
${diff_content}"

aichat -r commit -S -- "$prompt" 2>/dev/null \
  | awk 'NF { gsub(/^[0-9]+[.)]\s*/, ""); print; count++ } count==3 { exit }'
