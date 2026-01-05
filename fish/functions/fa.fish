function fa --description 'Fuzzy find aliases, abbreviations and functions'
    set -l items
    set -l tab (printf '\t')

    # Aliases: parse "alias name 'command'" format
    for line in (alias)
        set -l parts (string match -r "^alias (\S+)\s+'?(.+?)'?\$" -- $line)
        if test (count $parts) -ge 3
            set -a items "$parts[2]"$tab"alias"$tab"$parts[3]"
        end
    end

    # Abbreviations
    for ab in (abbr --list)
        set -l expansion (abbr --show | string match -e "-- $ab " | string replace -r "abbr -a --.* -- $ab '?(.+?)'?\$" '$1')
        if test -n "$expansion"
            set -a items "$ab"$tab"abbr"$tab"$expansion"
        else
            set -a items "$ab"$tab"abbr"$tab"-"
        end
    end

    # Functions: only from user config directories
    set -l user_paths "$HOME/.config/fish" "$__fish_config_dir"
    for fn in (functions --names)
        # Skip internal functions
        string match -qr '^(fish_|__)' -- $fn; and continue

        # Get function definition path
        set -l fn_path (functions --details $fn 2>/dev/null)
        test -z "$fn_path"; and continue

        # Only include functions from user config
        set -l is_user_func 0
        for upath in $user_paths
            if string match -q "$upath*" -- $fn_path
                set is_user_func 1
                break
            end
        end
        test $is_user_func -eq 0; and continue

        set -l desc (functions -D $fn 2>/dev/null)
        if test -n "$desc" -a "$desc" != "n/a" -a "$desc" != "-"
            set -a items "$fn"$tab"func"$tab"$desc"
        end
    end

    # Exit if no items
    if test (count $items) -eq 0
        echo "No aliases found"
        return 1
    end

    # FZF selection with tab delimiter
    set -l selected (printf '%s\n' $items | \
        column -t -s $tab | \
        fzf --header 'Aliases, Abbreviations & Functions' \
            --preview 'fish -c "type {1}"' \
            --preview-window=right:50%:wrap | \
        awk '{print $1}')

    # Insert into command line
    if test -n "$selected"
        commandline -i "$selected "
    end
end
