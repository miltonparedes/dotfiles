# WorkTrunk Shell Integration
if type -q wt; command wt config shell init fish | source; end

# ═══════════════════════════════════════════════════════════
# WorkTrunk Aliases - Ultra-efficient shortcuts
# ═══════════════════════════════════════════════════════════

# ─── Navegacion ────────────────────────────────────────────
# ws: switch to worktree (most frequent operation)
function ws --description 'Switch to worktree'
    wt switch $argv
end

# ws-: switch to previous worktree (like cd -)
function ws- --description 'Switch to previous worktree'
    wt switch -
end

# ws^: switch to default branch (main/master)
function 'ws^' --description 'Switch to default branch'
    wt switch '^'
end

# wtl: list all worktrees with status
function wtl --description 'List worktrees'
    wt list $argv
end

# ─── Creacion ──────────────────────────────────────────────
# wtc: create new worktree
function wtc --description 'Create new worktree'
    wt switch --create $argv
end

# wtcc: create worktree and launch Claude
function wtcc --description 'Create worktree + Claude'
    wt switch --create $argv[1] --execute claude $argv[2..-1]
end

# ─── Workflow ──────────────────────────────────────────────
# wtm: merge current branch to default
function wtm --description 'Merge to default branch'
    wt merge $argv
end

# wtr: remove current worktree
function wtr --description 'Remove worktree'
    wt remove $argv
end

# wtr!: force remove worktree (unmerged branches)
function 'wtr!' --description 'Force remove worktree'
    wt remove -D $argv
end

# ─── Step Operations ───────────────────────────────────────
# wtk: commit with LLM-generated message
function wtk --description 'Commit with LLM message'
    wt step commit $argv
end

# wtq: squash all commits since branching
function wtq --description 'Squash commits'
    wt step squash $argv
end

# wtb: rebase onto target branch
function wtb --description 'Rebase onto target'
    wt step rebase $argv
end

# wtp: push (fast-forward target to current)
function wtp --description 'Push to target'
    wt step push $argv
end

# ─── Extras ────────────────────────────────────────────────
# wtlf: list with full CI status
function wtlf --description 'List with CI status'
    wt list --full $argv
end

# wtlj: list as JSON (for scripting)
function wtlj --description 'List as JSON'
    wt list --format=json $argv
end

# wth: run hooks manually
function wth --description 'Run hooks'
    wt hook $argv
end
