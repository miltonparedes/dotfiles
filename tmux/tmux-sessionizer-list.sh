#!/usr/bin/env bash
# Helper: lists sessions (grouped) or windows for the sessionizer
# Field 1 is always the raw target name (for tmux switch-client)
# Field 2+ is the display text (shown via --with-nth=2..)

mode="$1"
target="$2"

if [ "$mode" = "windows" ]; then
  # Strip potential tree prefix from target (e.g. "┊ " or "  ")
  clean_target="${target##* }"
  [ -z "$clean_target" ] && clean_target="$target"
  tmux list-windows -t "$clean_target" -F "$clean_target:#{window_index}  #{window_name} #{?window_active,(active),}"
else
  # Collect all session names
  sessions=()
  while IFS= read -r line; do
    sessions+=("$line")
  done < <(tmux list-sessions -F '#{session_name} #{session_windows} #{?session_attached,1,0}' | sort)

  # Extract just names for parent detection
  names=()
  for entry in "${sessions[@]}"; do
    names+=("$(echo "$entry" | awk '{print $1}')")
  done

  for entry in "${sessions[@]}"; do
    name=$(echo "$entry" | awk '{print $1}')
    windows=$(echo "$entry" | awk '{print $2}')
    attached=$(echo "$entry" | awk '{print $3}')

    tag=""
    [ "$attached" = "1" ] && tag=" (attached)"

    # Find longest matching parent session
    parent=""
    for other in "${names[@]}"; do
      if [[ "$name" != "$other" && "$name" == "$other"-* ]]; then
        if [[ ${#other} -gt ${#parent} ]]; then
          parent="$other"
        fi
      fi
    done

    if [[ -n "$parent" ]]; then
      suffix="${name#"$parent"-}"
      printf "%s  \033[2m┊\033[0m \033[36m%s\033[0m  %sw%s\n" "$name" "$suffix" "$windows" "$tag"
    else
      printf "%s  \033[1m%s\033[0m  %sw%s\n" "$name" "$name" "$windows" "$tag"
    fi
  done
fi
