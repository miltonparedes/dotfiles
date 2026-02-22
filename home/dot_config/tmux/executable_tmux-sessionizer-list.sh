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
  done < <(tmux list-sessions -F '#{session_name} #{session_windows} #{?session_attached,1,0}' |
    awk 'BEGIN { low = sprintf("%c", 1) }
    {
      key = $1
      if (key ~ /-main$/) key = substr(key, 1, length(key) - 4) low "main"
      else if (key ~ /-master$/) key = substr(key, 1, length(key) - 6) low "master"
      print key "\t" $0
    }' | LC_ALL=C sort -k1,1 | cut -f2-)

  # Find the longest dash-boundary prefix of $1 shared with at least one other session
  _find_group_prefix() {
    local name="$1"
    local tmp="$name"
    while [[ "$tmp" == *-* ]]; do
      tmp="${tmp%-*}"
      for other in "${names[@]}"; do
        if [[ "$other" != "$name" && ( "$other" == "$tmp" || "$other" == "$tmp"-* ) ]]; then
          echo "$tmp"
          return
        fi
      done
    done
    echo ""
  }

  n=1
  emitted_virtual=()
  for entry in "${data[@]}"; do
    read -r name windows attached <<< "$entry"
    tag=""
    [ "$attached" = "1" ] && tag=" (attached)"

    # Find longest matching real parent session
    parent=""
    for other in "${names[@]}"; do
      [[ "$name" != "$other" && "$name" == "$other"-* && ${#other} -gt ${#parent} ]] && parent="$other"
    done

    # Check if this session is itself a parent of others
    has_children=0
    for other in "${names[@]}"; do
      [[ "$other" != "$name" && "$other" == "$name"-* ]] && has_children=1 && break
    done

    if [[ -n "$parent" ]]; then
      # Real parent exists — show as child
      printf "%s \033[2m%d ┊\033[0m %s  \033[2m%sw%s\033[0m\n" "$name" "$n" "${name#"$parent"-}" "$windows" "$tag"
    elif (( has_children )); then
      # This IS the parent session
      printf "%s \033[2m%d\033[0m %s  \033[2m%sw%s\033[0m\n" "$name" "$n" "$name" "$windows" "$tag"
    else
      # No real parent, no children — check for virtual group
      gpfx=$(_find_group_prefix "$name")
      if [[ -n "$gpfx" ]]; then
        already_emitted=0
        for v in "${emitted_virtual[@]}"; do
          [[ "$v" == "$gpfx" ]] && already_emitted=1 && break
        done
        suffix="${name#"$gpfx"-}"
        if (( ! already_emitted )); then
          emitted_virtual+=("$gpfx")
          # First child: show group prefix dim before ┊
          printf "%s \033[2m%d %s ┊\033[0m %s  \033[2m%sw%s\033[0m\n" "$name" "$n" "$gpfx" "$suffix" "$windows" "$tag"
        else
          # Subsequent children: spaces for alignment
          printf "%s \033[2m%d %*s ┊\033[0m %s  \033[2m%sw%s\033[0m\n" "$name" "$n" "${#gpfx}" "" "$suffix" "$windows" "$tag"
        fi
      else
        # Standalone session
        printf "%s \033[2m%d\033[0m %s  \033[2m%sw%s\033[0m\n" "$name" "$n" "$name" "$windows" "$tag"
      fi
    fi
    ((n++))
  done
fi
