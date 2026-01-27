function lumen-stacked --description 'Select commits with fzf and view in stacked mode'
    set -l range (git log --oneline -30 | fzf --multi --reverse \
        --header "TAB: multi-select | ENTER: confirmar")

    if test (count $range) -eq 0
        return 1
    end

    set -l first_sha (echo $range[1] | cut -d' ' -f1)
    set -l last_sha (echo $range[-1] | cut -d' ' -f1)

    if test "$first_sha" = "$last_sha"
        lumen diff $first_sha --stacked
    else
        lumen diff $last_sha..$first_sha --stacked
    end
end
