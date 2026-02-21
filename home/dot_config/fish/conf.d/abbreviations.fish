# ═══════════════════════════════════════════════════════════
# Shell Abbreviations
# Abbreviations expand inline before execution, allowing editing
# ═══════════════════════════════════════════════════════════

# ─── Git ──────────────────────────────────────────────────
# gaa: stage all changes
abbr -a gaa git add --all
# gcm: commit with message
abbr -a gcm git commit -m
# gca: amend last commit
abbr -a gca git commit --amend
# gcane: amend without editing message
abbr -a gcane git commit --amend --no-edit
# gpf: force push with lease (safe)
abbr -a gpf git push --force-with-lease
# glog: visual commit graph
abbr -a glog git log --oneline --graph --decorate
# grb: rebase
abbr -a grb git rebase
# grbi: interactive rebase
abbr -a grbi git rebase -i
# gst: stash changes
abbr -a gst git stash
# gstp: pop stashed changes
abbr -a gstp git stash pop
# grs: restore file
abbr -a grs git restore
# grss: unstage file
abbr -a grss git restore --staged

# ─── Docker Compose ───────────────────────────────────────
# dcu: start services
abbr -a dcu docker compose up
# dcd: stop services
abbr -a dcd docker compose down
# dcud: start services detached
abbr -a dcud docker compose up -d
# dcl: view logs
abbr -a dcl docker compose logs
# dclf: follow logs
abbr -a dclf docker compose logs -f
# dcr: restart services
abbr -a dcr docker compose restart

# ─── System Management ────────────────────────────────────
# sctl: systemctl
abbr -a sctl systemctl
# jctl: journalctl
abbr -a jctl journalctl
# jctlf: follow journal
abbr -a jctlf journalctl -f

# ─── Directory Navigation ─────────────────────────────────
# ...: go up 2 directories
abbr -a ... cd ../..
# ....: go up 3 directories
abbr -a .... cd ../../..
# .....: go up 4 directories
abbr -a ..... cd ../../../..

# ─── Common Typos ─────────────────────────────────────────
# gti: git typo fix
abbr -a gti git
# sl: ls typo fix
abbr -a sl ls
# al: la typo fix
abbr -a al la

# ─── Quick Commands ───────────────────────────────────────
# h: command history
abbr -a h history
# tf: terraform
abbr -a tf terraform
# py: python
abbr -a py python
# ipy: ipython REPL
abbr -a ipy ipython
# mk: create directory with parents
abbr -a mk mkdir -p
# rd: remove directory
abbr -a rd rmdir

# ─── Package Managers (OS-specific) ───────────────────────
if test (uname) = "Darwin"
    # bi: brew install
    abbr -a bi brew install
    # bu: brew update
    abbr -a bu brew update
    # bup: brew upgrade
    abbr -a bup brew upgrade
    # bs: brew search
    abbr -a bs brew search
else if test -f /etc/fedora-release
    # di: dnf install
    abbr -a di sudo dnf install
    # du: dnf update
    abbr -a du sudo dnf update
    # ds: dnf search
    abbr -a ds dnf search
    # dr: dnf remove
    abbr -a dr sudo dnf remove
end
