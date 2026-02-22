function fa --description 'Fuzzy find aliases, abbreviations and functions'
    set -l items
    set -l tab (printf '\t')

    # Build description map from source files
    # Format: parallel arrays for name -> description lookup
    set -l desc_names
    set -l desc_values
    set -l config_dir ~/.config/fish/conf.d
    # Read all config files including private/
    for src in $config_dir/*.fish $config_dir/private/*.fish
        if test -f $src
            for line in (cat $src)
                # Match comment format: "# name: description"
                if string match -qr '^\s*#\s*([^:]+):\s*(.+)$' -- $line
                    set -l parts (string match -r '^\s*#\s*([^:]+):\s*(.+)$' -- $line)
                    if test (count $parts) -ge 3
                        set -a desc_names $parts[2]
                        set -a desc_values $parts[3]
                    end
                end
            end
        end
    end

    # Aliases: only show documented ones (with # name: description comments)
    for line in (alias)
        set -l parts (string match -r "^alias (\S+)\s+'?(.+?)'?\$" -- $line)
        if test (count $parts) -ge 3
            set -l name $parts[2]
            set -l desc ""
            # Lookup description from comments
            for i in (seq (count $desc_names))
                if test "$desc_names[$i]" = "$name"
                    set desc $desc_values[$i]
                    break
                end
            end
            # Only show if documented
            if test -n "$desc"
                set -a items "$name"$tab"$desc"
            end
        end
    end

    # Abbreviations: only show documented ones
    for ab in (abbr --list)
        set -l desc ""
        # Lookup description from comments
        for i in (seq (count $desc_names))
            if test "$desc_names[$i]" = "$ab"
                set desc $desc_values[$i]
                break
            end
        end
        # Only show if documented
        if test -n "$desc"
            set -a items "$ab"$tab"$desc"
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

        # Get description from comments
        set -l desc ""
        for i in (seq (count $desc_names))
            if test "$desc_names[$i]" = "$fn"
                set desc $desc_values[$i]
                break
            end
        end

        # If no comment, try to extract from function definition
        if test -z "$desc"
            set -l fn_def (functions -v $fn 2>/dev/null | head -1)
            set -l fn_desc (string match -r -- "--description '([^']+)'" $fn_def)
            if test (count $fn_desc) -ge 2
                set desc $fn_desc[2]
            end
        end

        if test -n "$desc"
            set -a items "$fn"$tab"$desc"
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
            --preview 'fish -c "type {1} 2>/dev/null || abbr --show | grep -E \"-- {1} \" || echo \"(no definition found)\""' \
            --preview-window=right:50%:wrap | \
        awk '{print $1}')

    # Insert into command line
    if test -n "$selected"
        commandline -i "$selected "
    end
end
