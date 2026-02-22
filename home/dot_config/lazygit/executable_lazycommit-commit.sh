#!/usr/bin/env bash
set -euo pipefail

prompt_file="${1:-}"
if [ -z "$prompt_file" ]; then
  echo "Usage: lazycommit-commit.sh <prompt-file>" >&2
  exit 1
fi

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
target_prompts="$config_dir/.lazycommit.prompts.yaml"
backup_file=""

cleanup() {
  if [ -z "$backup_file" ]; then
    return
  fi
  if [ "$backup_file" = "__absent__" ]; then
    rm -f "$target_prompts"
  else
    cp -f "$backup_file" "$target_prompts"
    rm -f "$backup_file"
  fi
}

trap cleanup EXIT INT TERM

if [ -f "$target_prompts" ]; then
  backup_file="$(mktemp)"
  cp "$target_prompts" "$backup_file"
else
  backup_file="__absent__"
fi

cp "$prompt_file" "$target_prompts"

lazycommit commit
