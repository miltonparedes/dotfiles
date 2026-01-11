#!/bin/bash
# Minimal tmux stats: RAM + CPU temp + GPU temp

case "$(uname -s)" in
  Linux)
    # RAM: used/total (e.g. 6G/61G)
    ram=$(free -h | awk '/Mem:/ {gsub(/i/,"",$3); gsub(/i/,"",$2); printf "%s/%s", $3, $2}')

    # CPU temp via sensors (k10temp Tctl)
    cpu_temp=$(sensors 2>/dev/null | awk '/Tctl:/ {gsub(/\+/,""); printf "%.0f°", $2}')
    [ -z "$cpu_temp" ] && cpu_temp=$(sensors 2>/dev/null | awk '/^CPU:/ {gsub(/\+/,""); printf "%.0f°", $2}')

    # GPU temp via nvidia-smi
    if command -v nvidia-smi &>/dev/null; then
      gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null)
      [ -n "$gpu_temp" ] && gpu_temp="${gpu_temp}°"
    fi
    ;;

  Darwin)
    # RAM: used/total via vm_stat + sysctl
    pages=$(vm_stat | awk '/Pages active/ {gsub(/\./,""); print $3}')
    page_size=$(sysctl -n hw.pagesize)
    total=$(sysctl -n hw.memsize)
    used=$((pages * page_size / 1024 / 1024 / 1024))
    total_gb=$((total / 1024 / 1024 / 1024))
    ram="${used}G/${total_gb}G"

    # CPU temp via macmon pipe (if installed)
    if command -v macmon &>/dev/null; then
      cpu_temp=$(macmon pipe -s 1 2>/dev/null | jq -r '.temp.cpu_temp_avg // empty' | awk '{printf "%.0f°", $1}')
    fi
    [ -z "$cpu_temp" ] && cpu_temp="--"

    # GPU integrated in Apple Silicon (same as CPU)
    gpu_temp=""
    ;;
esac

# Output based on arguments
case "$1" in
  ram)  echo "$ram" ;;
  cpu)  echo "$cpu_temp" ;;
  gpu)  echo "$gpu_temp" ;;
  *)    # Default: todo junto
        out="$cpu_temp"
        [ -n "$gpu_temp" ] && out="$out $gpu_temp"
        out="$out | $ram"
        echo "$out"
        ;;
esac
