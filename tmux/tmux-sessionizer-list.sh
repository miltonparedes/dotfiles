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

  # Count sessions per prefix and check if prefix is a real session
  # (bash 3.x compatible — no associative arrays)
  prefixes=()
  prefix_counts=()
  prefix_real=()

  for name in "${names[@]}"; do
    pfx="${name%%-*}"
    # Find if this prefix is already tracked
    found=-1
    for i in "${!prefixes[@]}"; do
      if [[ "${prefixes[$i]}" == "$pfx" ]]; then
        found=$i
        break
      fi
    done
    if (( found == -1 )); then
      prefixes+=("$pfx")
      prefix_counts+=(1)
      if [[ "$name" == "$pfx" ]]; then prefix_real+=(1); else prefix_real+=(0); fi
    else
      prefix_counts[$found]=$(( ${prefix_counts[$found]} + 1 ))
      [[ "$name" == "$pfx" ]] && prefix_real[$found]=1
    fi
  done

  # Helper: look up prefix info by name
  _pfx_index() {
    local p="$1"
    for i in "${!prefixes[@]}"; do
      [[ "${prefixes[$i]}" == "$p" ]] && echo "$i" && return
    done
    echo -1
  }

  n=1
  emitted_virtual=()
  for entry in "${data[@]}"; do
    read -r name windows attached <<< "$entry"
    tag=""
    [ "$attached" = "1" ] && tag=" (attached)"
    pfx="${name%%-*}"
    pi=$(_pfx_index "$pfx")

    if (( pi >= 0 && ${prefix_counts[$pi]} >= 2 )); then
      # This session belongs to a group

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

      if [[ -z "$parent" && "$name" != "$pfx" && "${prefix_real[$pi]}" == "0" && "$has_children" == "0" ]]; then
        # No real parent exists — emit virtual header if not yet emitted
        already_emitted=0
        for v in "${emitted_virtual[@]}"; do
          [[ "$v" == "$pfx" ]] && already_emitted=1 && break
        done
        if (( ! already_emitted )); then
          printf "__group__:%s \033[2;3m%s\033[0m\n" "$pfx" "$pfx"
          emitted_virtual+=("$pfx")
        fi
        # Print as child of virtual group
        printf "%s \033[2m%d\033[0m \033[2m┊\033[0m \033[36m%s\033[0m  %sw%s\n" "$name" "$n" "${name#"$pfx"-}" "$windows" "$tag"
      elif [[ -n "$parent" ]]; then
        # Real parent exists — show as child (existing behavior)
        printf "%s \033[2m%d\033[0m \033[2m┊\033[0m \033[36m%s\033[0m  %sw%s\n" "$name" "$n" "${name#"$parent"-}" "$windows" "$tag"
      else
        # This IS the parent session (or prefix matches itself)
        printf "%s \033[2m%d\033[0m \033[1m%s\033[0m  %sw%s\n" "$name" "$n" "$name" "$windows" "$tag"
      fi
    else
      # Standalone session — no group
      printf "%s \033[2m%d\033[0m \033[1m%s\033[0m  %sw%s\n" "$name" "$n" "$name" "$windows" "$tag"
    fi
    ((n++))
  done
fi
