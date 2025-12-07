# Fish Shell Aliases
# Compatible with both macOS and Bluefin/Fedora

# Navigation
alias ..='z ..'

# Enhanced ls with eza
if command -q eza
    alias ls='eza'
    alias lst='eza -T'
    alias ll='eza -l -o'
    alias la='eza -a'
else
    alias ll='ls -l'
    alias la='ls -la'
end

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Grep with color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Shortcuts
alias j='just'
alias lg='lazygit'

# SSH shortcuts
alias sb='ssh box'

# Git shortcuts (additional)
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Docker shortcuts (if docker is installed)
if command -q docker
    alias d='docker'
    alias dc='docker compose'
    alias dps='docker ps'
    alias di='docker images'
end

# Python shortcuts (if python is installed)
if command -q python3
    alias python='python3'
    alias pip='pip3'
end

# Editor shortcuts
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# System shortcuts
if test (uname) = "Darwin"
    # macOS specific
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
    alias flushdns='sudo dscacheutil -flushcache'
else if test -f /etc/fedora-release
    # Fedora/Bluefin specific
    alias update='sudo dnf update'
    alias search='dnf search'
    alias install='sudo dnf install'
end

# Reload fish configuration
alias reload='source ~/.config/fish/config.fish'

# Clear screen
alias c='clear'

# Weather (fun extra)
alias weather='curl wttr.in'

# Quick edit configs
alias fishconfig='nvim ~/.config/fish/config.fish'
alias nvimconfig='nvim ~/.config/nvim/init.lua'