#!/usr/bin/env bash
# Helper: lists sessions (grouped) or windows for the sessionizer
# Field 1 is always the raw target name (for tmux switch-client)
# Field 2+ is the display text (shown via --with-nth=2..)

mode="$1"
target="$2"

if [ "$mode" = "windows" ]; then
  n=1
  while IFS=' ' read -r tgt rest; do
    printf "%s \033[2m%d\033[0m %s\n" "$tgt" "$n" "$rest"
    ((n++))
  done < <(tmux list-windows -t "$target" -F "$target:#{window_index}  #{window_name} #{?window_active,(active),}")
else
  # Single tmux call, parse with bash builtins only
  names=()
  data=()
  while IFS=' ' read -r name windows attached; do
    names+=("$name")
    data+=("$name $windows $attached")
  done < <(tmux list-sessions -F '#{session_name} #{session_windows} #{?session_attached,1,0}' | sort)

  n=1
  for entry in "${data[@]}"; do
    read -r name windows attached <<< "$entry"
    tag=""
    [ "$attached" = "1" ] && tag=" (attached)"

    # Find longest matching parent
    parent=""
    for other in "${names[@]}"; do
      [[ "$name" != "$other" && "$name" == "$other"-* && ${#other} -gt ${#parent} ]] && parent="$other"
    done

    if [[ -n "$parent" ]]; then
      printf "%s \033[2m%d\033[0m \033[2m┊\033[0m \033[36m%s\033[0m  %sw%s\n" "$name" "$n" "${name#"$parent"-}" "$windows" "$tag"
    else
      printf "%s \033[2m%d\033[0m \033[1m%s\033[0m  %sw%s\n" "$name" "$n" "$name" "$windows" "$tag"
    fi
    ((n++))
  done
fi
