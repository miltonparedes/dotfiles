function fa --description 'Fuzzy find aliases, abbreviations and functions'
    set -l items

    # Aliases: parse "alias name 'command'" format
    for line in (alias)
        set -l parts (string match -r "^alias (\S+)\s+'?(.+?)'?\$" -- $line)
        if test (count $parts) -ge 3
            set -a items "$parts[2]\talias\t$parts[3]"
        end
    end

    # Abbreviations
    for ab in (abbr --list)
        set -l expansion (abbr --show | string match -e "-- $ab " | string replace -r "abbr -a --.* -- $ab '?(.+?)'?\$" '$1')
        if test -n "$expansion"
            set -a items "$ab\tabbr\t$expansion"
        else
            set -a items "$ab\tabbr\t-"
        end
    end

    # Functions with descriptions (exclude internal fish_* and __*)
    for fn in (functions --names)
        # Skip internal functions
        string match -qr '^(fish_|__)' -- $fn; and continue

        set -l desc (functions -D $fn 2>/dev/null)
        if test -n "$desc" -a "$desc" != "n/a" -a "$desc" != "-"
            set -a items "$fn\tfunc\t$desc"
        end
    end

    # Exit if no items
    if test (count $items) -eq 0
        echo "No aliases found"
        return 1
    end

    # FZF selection
    set -l selected (printf '%s\n' $items | \
        column -t -s \t | \
        fzf --header 'Aliases, Abbreviations & Functions' \
            --preview 'type (echo {} | awk \'{print $1}\')' \
            --preview-window=right:50%:wrap | \
        awk '{print $1}')

    # Insert into command line
    if test -n "$selected"
        commandline -i "$selected "
    end
end
