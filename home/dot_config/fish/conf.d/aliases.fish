# ═══════════════════════════════════════════════════════════
# Shell Aliases
# Compatible with both macOS and Bluefin/Fedora
# ═══════════════════════════════════════════════════════════

# ─── Navigation ───────────────────────────────────────────
# ..: go up one directory
alias .. 'z ..'

# ─── Enhanced ls (eza) ────────────────────────────────────
if command -q eza
    # ls: list files with eza
    alias ls eza
    # lst: list files as tree
    alias lst 'eza -T'
    # ll: long listing with octal permissions
    alias ll 'eza -l -o'
    # la: list all including hidden
    alias la 'eza -a'
else
    # ll: long listing
    alias ll 'ls -l'
    # la: list all including hidden
    alias la 'ls -la'
end

# ─── Safety ───────────────────────────────────────────────
# rm: remove with confirmation
alias rm 'rm -i'
# cp: copy with confirmation
alias cp 'cp -i'
# mv: move with confirmation
alias mv 'mv -i'

# ─── Grep ─────────────────────────────────────────────────
# grep: search with color
alias grep 'grep --color=auto'
# egrep: extended grep with color
alias egrep 'egrep --color=auto'
# fgrep: fixed string grep with color
alias fgrep 'fgrep --color=auto'

# ─── Shortcuts ────────────────────────────────────────────
# j: just command runner
alias j just
# lazygit: TUI (COLORTERM needed for delta true color)
alias lazygit 'COLORTERM=truecolor command lazygit'
alias lg lazygit

# ─── Git ──────────────────────────────────────────────────
# g: git shortcut
alias g git
# gs: show working tree status
alias gs 'git status'
# ga: stage files
alias ga 'git add'
# gc: create commit
alias gc 'git commit'
# gp: push to remote
alias gp 'git push'
# gl: pull from remote
alias gl 'git pull'
# gd: show changes
alias gd 'git diff'
# gco: switch branches
alias gco 'git checkout'
# gb: list/create branches
alias gb 'git branch'

# ─── Docker ───────────────────────────────────────────────
if command -q docker
    # d: docker shortcut
    alias d docker
    # dc: docker compose
    alias dc 'docker compose'
    # dps: list running containers
    alias dps 'docker ps'
    # di: list images
    alias di 'docker images'
end

# ─── Python ───────────────────────────────────────────────
if command -q python3
    # python: use python3
    alias python python3
    # pip: use pip3
    alias pip pip3
end

# ─── Editor ───────────────────────────────────────────────
# v: neovim
alias v nvim
# vi: neovim
alias vi nvim
# vim: neovim
alias vim nvim

# ─── System (OS-specific) ─────────────────────────────────
if test (uname) = "Darwin"
    # showfiles: show hidden files in Finder
    alias showfiles 'defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
    # hidefiles: hide hidden files in Finder
    alias hidefiles 'defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
    # flushdns: clear DNS cache
    alias flushdns 'sudo dscacheutil -flushcache'
else if test -f /etc/fedora-release
    # update: update system packages
    alias update 'sudo dnf update'
    # search: search packages
    alias search 'dnf search'
    # install: install package
    alias install 'sudo dnf install'
end

# ─── Shell ────────────────────────────────────────────────
# reload: reload fish configuration
alias reload 'source ~/.config/fish/config.fish'
# c: clear terminal
alias c clear

# ─── Fun ──────────────────────────────────────────────────
# weather: show weather forecast
alias weather 'curl wttr.in'

# ─── Config Editing ───────────────────────────────────────
# fishconfig: edit fish config
alias fishconfig 'nvim ~/.config/fish/config.fish'
# nvimconfig: edit neovim config
alias nvimconfig 'nvim ~/.config/nvim/init.lua'

# ─── Tmux ─────────────────────────────────────────────────
# t: start tmux with 256 colors
# tmux aliases moved to tmux.fish
alias t 'tmux -2'
alias tk 'tmux kill-session'

# ─── Coding Agents ────────────────────────────────────────
# cc: Claude Code CLI without permission prompts
alias cc 'claude --dangerously-skip-permissions'

# gem: Gemini CLI
alias gem gemini

# co: OpenCode CLI
alias co opencode

# cx: Codex CLI (defaults to full-auto + search via config.toml)
alias cx codex
# codex-yolo: Codex CLI with full-auto and search
alias codex-yolo 'codex --search --full-auto'
# cxx: Codex CLI exec mode (non-interactive)
alias cxx 'codex exec'
# cxr: Codex CLI resume last session
alias cxr 'codex resume --last'
# cxf: Codex CLI fork last session
alias cxf 'codex fork --last'
# cxw: Codex CLI code review
alias cxw 'codex review'
# cxa: Codex CLI apply last diff
alias cxa 'codex apply'
# cxy: Codex CLI danger mode (no approvals, no sandbox)
alias cxy 'codex --dangerously-bypass-approvals-and-sandbox'

# i: AIChat interactive
alias i aichat
# ie: AIChat execute mode
alias ie 'aichat -e'

# ccu: Claude Code usage stats
alias ccu 'bunx ccusage'

# ─── Chrome DevTools ──────────────────────────────────────
# chrome-debug: launch Chrome with remote debugging
if command -q flatpak
    alias chrome-debug 'flatpak run com.google.Chrome --remote-debugging-port=9222 --ozone-platform=wayland --user-data-dir=/tmp/chrome-debug'
else if test (uname) = "Darwin"
    alias chrome-debug '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug'
else
    alias chrome-debug 'google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug'
end
