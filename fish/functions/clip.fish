function clip --description 'Copy to clipboard via OSC 52 (works over SSH + tmux)'
    set -l data
    if test (count $argv) -gt 0
        set data "$argv"
    else
        set data (cat)
    end
    printf '\033]52;c;%s\a' (printf '%s' "$data" | base64 | tr -d '\n')
end
