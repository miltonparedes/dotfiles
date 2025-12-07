# Fish Shell Abbreviations
# Abbreviations are more powerful than aliases in fish
# They expand inline before execution, allowing further editing

# Git abbreviations (expand inline for modification)
abbr -a gaa git add --all
abbr -a gcm git commit -m
abbr -a gca git commit --amend
abbr -a gcane git commit --amend --no-edit
abbr -a gpf git push --force-with-lease
abbr -a glog git log --oneline --graph --decorate
abbr -a grb git rebase
abbr -a grbi git rebase -i
abbr -a gst git stash
abbr -a gstp git stash pop
abbr -a grs git restore
abbr -a grss git restore --staged

# Docker compose abbreviations
abbr -a dcu docker compose up
abbr -a dcd docker compose down
abbr -a dcud docker compose up -d
abbr -a dcl docker compose logs
abbr -a dclf docker compose logs -f
abbr -a dcr docker compose restart

# System management
abbr -a sctl systemctl
abbr -a jctl journalctl
abbr -a jctlf journalctl -f

# Directory navigation
abbr -a ... cd ../..
abbr -a .... cd ../../..
abbr -a ..... cd ../../../..

# Common typos
abbr -a gti git
abbr -a sl ls
abbr -a al la
abbr -a ll la

# Quick commands
abbr -a h history
abbr -a k kubectl
abbr -a tf terraform
abbr -a py python
abbr -a ipy ipython
abbr -a mk mkdir -p
abbr -a rd rmdir

# Package managers
if test (uname) = "Darwin"
    abbr -a bi brew install
    abbr -a bu brew update
    abbr -a bup brew upgrade
    abbr -a bs brew search
else if test -f /etc/fedora-release
    abbr -a di sudo dnf install
    abbr -a du sudo dnf update
    abbr -a ds dnf search
    abbr -a dr sudo dnf remove
end