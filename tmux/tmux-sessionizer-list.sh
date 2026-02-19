#!/usr/bin/env bash
# Helper: lists sessions (grouped) or windows for the sessionizer
# Field 1 is always the raw target name (for tmux switch-client)
# Field 2+ is the display text (shown via --with-nth=2..)

mode="$1"
target="$2"

if [ "$mode" = "windows" ]; then
  n=1
  if [[ "$target" == __group__:* ]]; then
    # Virtual group: list windows from all sessions sharing this prefix
    prefix="${target#__group__:}"
    while IFS=' ' read -r sess_name _rest; do
      [[ "$sess_name" == "$prefix"-* || "$sess_name" == "$prefix" ]] || continue
      label="${sess_name#"$prefix"-}"
      [ "$label" = "$sess_name" ] && label="$sess_name"
      while IFS=' ' read -r windex wname wactive; do
        printf "%s:%s \033[2m%d\033[0m \033[2m%s›\033[0m %s %s\n" "$sess_name" "$windex" "$n" "$label" "$wname" "$wactive"
        ((n++))
      done < <(tmux list-windows -t "$sess_name" -F '#{window_index} #{window_name} #{?window_active,(active),}')
    done < <(tmux list-sessions -F '#{session_name} x' | sort)
  else
    while IFS=' ' read -r tgt rest; do
      printf "%s \033[2m%d\033[0m %s\n" "$tgt" "$n" "$rest"
      ((n++))
    done < <(tmux list-windows -t "$target" -F "$target:#{window_index}  #{window_name} #{?window_active,(active),}")
  fi
else
  # Single tmux call, parse with bash builtins only
  names=()
  data=()
  while IFS=' ' read -r name windows attached; do
    names+=("$name")
    data+=("$name $windows $attached")
  done < <(tmux list-sessions -F '#{session_name} #{session_windows} #{?session_attached,1,0}' | sort)

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
      printf "%s \033[2m%d\033[0m \033[2m┊\033[0m \033[36m%s\033[0m  %sw%s\n" "$name" "$n" "${name#"$parent"-}" "$windows" "$tag"
    elif (( has_children )); then
      # This IS the parent session
      printf "%s \033[2m%d\033[0m \033[1m%s\033[0m  %sw%s\n" "$name" "$n" "$name" "$windows" "$tag"
    else
      # No real parent, no children — check for virtual group
      gpfx=$(_find_group_prefix "$name")
      if [[ -n "$gpfx" ]]; then
        # Emit virtual group header once
        already_emitted=0
        for v in "${emitted_virtual[@]}"; do
          [[ "$v" == "$gpfx" ]] && already_emitted=1 && break
        done
        if (( ! already_emitted )); then
          printf "__group__:%s \033[2;3m%s\033[0m\n" "$gpfx" "$gpfx"
          emitted_virtual+=("$gpfx")
        fi
        # Print as child of virtual group
        printf "%s \033[2m%d\033[0m \033[2m┊\033[0m \033[36m%s\033[0m  %sw%s\n" "$name" "$n" "${name#"$gpfx"-}" "$windows" "$tag"
      else
        # Standalone session
        printf "%s \033[2m%d\033[0m \033[1m%s\033[0m  %sw%s\n" "$name" "$n" "$name" "$windows" "$tag"
      fi
    fi
    ((n++))
  done
fi
